# claude-progress.md

> **Read this first.** This file is the durable handoff between agent
> sessions. It tells you the current state, what is in flight, what is
> broken, and the next action.

## Next action (read this before doing anything else)

Run `./init.sh`, then `npm install` if you haven't yet, then `npm run verify`.
Once those are green, mark feature `harness-001` as `done` in
`feature_list.json` with the commit SHA from the bring-up commit, and add an
entry to the "Completed" section below. After that, the next available work is
`ui-001` (Home screen shows project name and harness status).

## Current state

- **Branch:** main (no git history yet — initial scaffold)
- **Baseline verify:** unknown (not yet run after scaffold)
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
