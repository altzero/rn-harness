# claude-progress.md

> **Read this first.** This file is the durable handoff between agent
> sessions. It tells you the current state, what is in flight, what is
> broken, and the next action.

## Next action (read this before doing anything else)

You are on `feat/e2e-001-maestro`. The Maestro toolchain has been
scaffolded but **not yet exercised** on a real simulator (the scaffolding
session ran on a machine without Xcode). To close out `e2e-001`:

1. `./init.sh && npm run verify` — confirm baseline green on your machine
   (the lockfile from `harness-001` ships with main; install + verify
   should be quick).
2. Install Maestro: `curl -Ls 'https://get.maestro.mobile.dev' | bash`.
3. Boot an iOS sim: `npm run sim:ios`.
4. Start the app on the sim: `npm run ios` (Expo will install Expo Go or
   the dev client; use the appropriate `appId` — see `.maestro/config.yaml`).
5. Run the flow: `npm run e2e`. Confirm exit 0 and a screenshot in
   `tmp/diagnostics/`.
6. Flip `e2e-001` to `status: "done"`, `passes: true`, record the commit
   SHA, then merge `feat/e2e-001-maestro` into `main`.

Once `e2e-001` is done, the next available work is `ui-001` (Home screen
shows project name and harness status).

## Current state

- **Branch:** feat/e2e-001-maestro (off main; harness-001 already merged
  into main as part of PR #1)
- **Baseline verify:** GREEN at d04fc81 (the harness-001 close commit
  now in main)
- **In progress:** `e2e-001` (Maestro smoke flow runs on a local simulator)
- **Blocked:** none
- **Known issues:** none

## Completed

### harness-001 — Harness scaffolding present and verified  ✓

Closed at SHA d04fc81 on 2026-05-19, merged to main as PR #1 ("Initial
harness setup").

- `./init.sh` exits 0 on a fresh checkout (npm install adds 1052 packages
  in ~1m, then typecheck/lint/schema pass).
- `npm run verify` exits 0; 6/6 jest tests pass.
- AGENTS.md, CLAUDE.md, docs/HARNESS.md, docs/ARCHITECTURE.md, and the
  rest of the harness scaffolding are present.
- feature_list.json validates against scripts/feature-list-check.js.

Surfaced one real issue during verification: the speculative
`@testing-library/jest-native` + `@testing-library/react-native` devDeps
peer-conflicted with React 19.1 (Expo SDK 54's pin). Removed in d04fc81.
This is the lecture-06 win — init.sh caught a broken foundation that
would otherwise have shipped silently.

## Known issues

_(none yet)_

## Decisions log

> Append a dated entry whenever you make a non-obvious choice. This is the
> equivalent of an architecture decision record, but tuned to the
> session-by-session rhythm of harness-engineering work.

- **2026-05-19** — Chose Expo over bare React Native CLI. **Why:** Expo
  SDK 54 supports the full RN feature set we need, gives us EAS for builds,
  and avoids `ios/`/`android/` drift between agent sessions (a core pain
  point harness engineering exists to solve). **Trade-off:** can't add
  arbitrary native modules without a config plugin or `expo prebuild`.

- **2026-05-19** — Adopted Expo Router (file-based routing under `app/`).
  **Why:** matches Next.js mental model that most agents have strong priors
  about; reduces "guess the file" mistakes.

- **2026-05-19** — Removed `@testing-library/jest-native` and
  `@testing-library/react-native` from devDeps during harness-001 close.
  **Why:** Speculative — added for the `ui-001`/`ui-002` render-test
  verification items, but ERESOLVE'd against React 19.1 (Expo SDK 54). No
  test in the repo actually uses them yet. Re-add at the version that
  matches RN/React at the time `ui-001` is picked up.

- **2026-05-19** — Chose Maestro (not Detox or Playwright) for the
  feature-verification E2E layer. **Why:** Playwright drives web only, not
  Hermes/native; Detox needs heavy per-feature wiring; Maestro is a
  single-binary YAML runner whose flows an agent can easily author and
  whose output (logs + screenshots + JUnit XML) feeds directly into the
  harness's `verification[]` mechanism. **Trade-off:** less fine-grained
  control than Detox; for complex gesture flows we may need to revisit.

- **2026-05-19** — Sim helpers (`scripts/sim-ios.sh`, `scripts/sim-android.sh`)
  are deliberately separate from `npm run ios/android`. **Why:** booting
  the sim and building/installing the app are two different concerns. An
  agent should be able to boot the foundation cheaply, run multiple flows
  against the same booted state, and screenshot without re-building.

## Sessions

### Session 2026-05-19 (agent: claude) — merged main into feat/e2e-001-maestro

- Picked up: e2e-001 (already in_progress on this branch).
- Did: PR #1 ("Initial harness setup") had merged `chore/harness-001-close`
  into main, which conflicted with this branch's `claude-progress.md`.
  Merged main back in and resolved the conflict by keeping both
  narratives (harness-001 closed + e2e-001 scaffolded). `feature_list.json`
  and `package.json` auto-merged cleanly.
- Verify: pending (needs npm install + verify after the merge).
- Left: e2e-001 still in_progress on this branch. Open the PR after the
  merge commit lands on origin.

### Session 2026-05-19 (agent: claude) — cut feat/e2e-001-maestro

- Picked up: e2e-001 (scaffolding portion only)
- Did: cut branch `feat/e2e-001-maestro`. Added `.maestro/{config.yaml,README.md,flows/home.yaml}`,
  `scripts/{run-maestro.sh,sim-ios.sh,sim-android.sh}`, npm scripts
  (`sim:ios`, `sim:android`, `e2e`, `e2e:ios`, `e2e:android`), and the
  `e2e-001` feature entry. Updated decisions log and Next action.
- Verify: not run on a simulator (no Xcode in scaffolding environment).
  All shell scripts pass `bash -n`; `feature_list.json` validates.
- Left: `e2e-001` in `todo` with scaffolding complete. The single
  remaining step is running the flow on a real sim and recording the
  artifacts. **WIP=1** is preserved.
- Watch out: the default `appId` in `.maestro/config.yaml` is
  `host.exp.exponent` (Expo Go). For a dev build, set
  `ios.bundleIdentifier` + `android.package` in `app.json` and update
  `config.yaml` to match. The flow accepts `${APP_ID}` env override.

### Session 2026-05-19 (agent: claude) — closed harness-001

- Picked up: harness-001 (was in_progress on main).
- Did: ran `./init.sh` on a fresh checkout → caught ERESOLVE on speculative
  test deps. Removed them from `devDependencies`. Re-ran `./init.sh` →
  green. Ran `npm run verify` → all four steps green, 6/6 tests pass.
  Committed lockfile + dep cleanup at d04fc81. Flipped harness-001 to
  `done` with that SHA.
- Verify: green at d04fc81 (tsc, expo lint, 6 jest tests, schema).
- Left: WIP=0; next = ui-001. Merged via PR #1.
- Watch out: node v23.5.0 prints an EBADENGINE warning for
  `eslint-visitor-keys` (wants Node 20/22/24). Benign — install completes
  and verify passes. If we want to silence it, downgrade to Node 22 LTS.

## Handoff template

When ending a session, append a section like this:

```
## Session 2026-MM-DD (agent: <name>)

- Picked up: <feature id>
- Did:       <one-paragraph diff summary>
- Verify:    green | red (link to failing output)
- Left:      <feature id> in <status>; next action = <one sentence>
- Watch out: <anything surprising the next session should know>
```
