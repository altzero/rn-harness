# AGENTS.md

This is a React Native (Expo SDK 54) project organized around [harness
engineering](https://walkinglabs.github.io/learn-harness-engineering).
Keep this file short — it's a router into the system-of-record docs,
not an instruction dump.

> If a fact about how to work in this repo isn't in a file, it doesn't
> exist. Add it before you act on memory.

## Startup workflow

1. `pwd` — confirm repo root ends in `/rn-harness`.
2. Read `PROGRESS.md` (small) — recover state, see the next best step.
3. List `features/` — see which features are `done`, `in_progress`,
   or `blocked`.
4. `./init.sh` — fail loudly if the foundation is broken.
5. `npm run verify` — baseline must be green before new work.
6. Pick the highest-priority `in_progress` feature, else the next
   `todo`. Work only on that until verified or blocked. **WIP = 1.**

## Routing

| Doc | What it covers |
| --- | --- |
| `docs/HARNESS.md` | working contract, naming standard, DoD |
| `docs/SESSION.md` | end-of-session checklist, PR template |
| `docs/ARCHITECTURE.md` | layer model, folder map |
| `docs/RN_PLATFORM.md` | Expo / Metro / Hermes / EAS rules |
| `PROGRESS.md` | current state, next steps |
| `DECISIONS.md` | append-only design decisions |
| `features/*.json` | machine-readable scope, one feature per file |
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

Run `docs/SESSION.md`. In one sentence: verify green, update
`PROGRESS.md` + the relevant `features/<id>.json`, commit, open a PR if the branch
is reviewable, run `npm run harness:clean-state`.
