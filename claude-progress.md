# claude-progress.md

> **Read this first.** This file is the durable handoff between agent
> sessions. It tells you the current state, what is in flight, what is
> broken, and the next action.

## Next action (read this before doing anything else)

The bring-up is complete — `harness-001` is closed at SHA d04fc81 with a
green baseline (typecheck, lint, 6 jest tests, schema all pass). The next
available work is **`ui-001`** (Home screen shows project name and harness
status). To pick it up:

1. `./init.sh && npm run verify` — confirm baseline green on your machine.
2. Move `ui-001` to `status: "in_progress"`, set `owner`.
3. Implement per the verification list in `feature_list.json`.

There are also two open branches with unmerged work:

- **feat/e2e-001-maestro** — adds Maestro toolchain + sample flow + sim helpers.
  Conflicts with this branch on `package.json`, `claude-progress.md`, and
  `feature_list.json`. Merge or rebase before continuing.
- **feat/ci-001-actions** — adds GitHub Actions for static + e2e gates (planned).

## Current state

- **Branch:** chore/harness-001-close
- **Baseline verify:** GREEN at d04fc81
- **In progress:** none (WIP=0, free to pick up ui-001)
- **Blocked:** none
- **Known issues:** none

## Completed

### harness-001 — Harness scaffolding present and verified  ✓

Closed at SHA d04fc81 on 2026-05-19.

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

## Sessions

### Session 2026-05-19 (agent: claude) — closed harness-001

- Picked up: harness-001 (was in_progress on main).
- Did: ran `./init.sh` on a fresh checkout → caught ERESOLVE on speculative
  test deps. Removed them from `devDependencies`. Re-ran `./init.sh` →
  green. Ran `npm run verify` → all four steps green, 6/6 tests pass.
  Committed lockfile + dep cleanup at d04fc81. Flipped harness-001 to
  `done` with that SHA.
- Verify: green at d04fc81 (tsc, expo lint, 6 jest tests, schema).
- Left: WIP=0; next = ui-001. Two open branches (feat/e2e-001-maestro,
  feat/ci-001-actions) need merging or rebasing before ui-001 work.
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
