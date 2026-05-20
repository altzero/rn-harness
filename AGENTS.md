# AGENTS.md

This is a React Native (Expo SDK 54) project organized around [harness
engineering](https://walkinglabs.github.io/learn-harness-engineering).
Keep this file short — it's a router into the system-of-record docs,
not an instruction dump.

> If a fact about how to work in this repo isn't in a file, it doesn't
> exist. Add it before you act on memory.

## Startup workflow

1. `pwd` — confirm repo root ends in `/rn-harness`.
2. `npm run harness:features` — one-line summary of `features/`.
3. List `features/` — pick the highest-priority `in_progress`
   feature, else the next `todo`. Work only on that until verified
   or blocked. **WIP = 1.**
4. `./init.sh` — fail loudly if the foundation is broken.
5. `npm run verify` — baseline must be green before new work.
6. Skim recent commits / open PRs for the per-branch session context
   (PR descriptions carry it; `gh pr list` and `gh pr view <n>`).

## Routing

| Doc | What it covers |
| --- | --- |
| `docs/HARNESS.md` | working contract, naming standard, DoD |
| `docs/SESSION.md` | end-of-session checklist, PR template |
| `docs/ARCHITECTURE.md` | layer model, folder map |
| `docs/RN_PLATFORM.md` | Expo / Metro / Hermes / EAS rules |
| `DECISIONS.md` | append-only design decisions |
| `features/*.json` | machine-readable scope; status, verification list, notes per feature |
| `.maestro/README.md` | E2E flow authoring |

## Hard rules

- **WIP = 1.** One feature at a time.
- **No declaring victory without evidence.** The `verification` list in
  `features/<id>.json` must have been performed before flipping to `done`.
- **Don't edit `ios/` / `android/`.** Native config goes through
  `app.json` + config plugins. See `docs/RN_PLATFORM.md`.
- **Pin behavior to versions.** Expo SDK 54 — read
  https://docs.expo.dev/versions/v54.0.0/ when in doubt.
- **Don't skip type / lint / test failures.** Reset Metro cache only
  as diagnosis, never as fix.

## End of session

Run `docs/SESSION.md`. The shortest version:

1. `npm run verify` — must be green.
2. Update the in-flight `features/<id>.json` (status, notes).
3. **Before merging**, flip status to `done` with `commitSha` set
   to the latest branch tip. The merge then carries the closed
   feature into main as part of its own diff. **No follow-up
   bookkeeping commit needed.**
4. Commit, push, open a PR if the branch is reviewable.
5. `npm run harness:clean-state`.
