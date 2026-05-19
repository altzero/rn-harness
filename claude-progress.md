# claude-progress.md

> **Read this first.** This file is the durable handoff between agent
> sessions. It tells you the current state, what is in flight, what is
> broken, and the next action.

## Next action (read this before doing anything else)

You are on branch `feat/e2e-001-maestro`. The Maestro toolchain has been
scaffolded but **not yet exercised** on a real simulator (the scaffolding
session ran on a machine without Xcode). To pick this up:

1. From this branch: `npm install` (if you haven't), `./init.sh`,
   `npm run verify`. All must be green before moving on.
2. Install Maestro: `curl -Ls 'https://get.maestro.mobile.dev' | bash`.
3. Boot an iOS sim: `npm run sim:ios`.
4. Start the app on the sim: `npm run ios` (Expo will install Expo Go or
   the dev client; use the appropriate `appId` — see `.maestro/config.yaml`).
5. Run the flow: `npm run e2e`. Confirm exit 0 and a screenshot in
   `tmp/diagnostics/`.
6. Flip `e2e-001` to `status: "done"`, `passes: true`, record the commit
   SHA, then merge `feat/e2e-001-maestro` into `main`.

Once `e2e-001` is done, the next available work is still `harness-001`
(initial bring-up verification) → then `ui-001`.

## Current state

- **Branch:** feat/e2e-001-maestro (off main at d74a40c)
- **Baseline verify:** unknown (not yet run end-to-end)
- **In progress:** `harness-001` (Harness scaffolding present and verified)
- **Blocked:** none
- **Known issues:** none

## Completed

_(empty — bring-up is in progress)_

## In progress

### harness-001 — Harness scaffolding present and verified

The repo was scaffolded from `create-expo-app` and then the harness files
(`AGENTS.md`, `CLAUDE.md`, `init.sh`, `feature_list.json`,
`claude-progress.md`, `docs/*`, `scripts/*`) were added on top. Remaining
work: run `./init.sh` and `npm run verify` end-to-end on a fresh install,
then flip the feature to `done`.

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
  artifacts. **WIP=1** is preserved — `harness-001` remains the only
  `in_progress` feature.
- Watch out: the default `appId` in `.maestro/config.yaml` is
  `host.exp.exponent` (Expo Go). For a dev build, set
  `ios.bundleIdentifier` + `android.package` in `app.json` and update
  `config.yaml` to match. The flow accepts `${APP_ID}` env override.

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
