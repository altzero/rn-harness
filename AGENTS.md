# AGENTS.md

This repository is a React Native (Expo) project organized around **harness
engineering** — a discipline that treats the repo as the system of record for
AI agents and humans alike. Keep this file short. Use it as the routing layer
into the system-of-record docs, not as a giant instruction dump.

> If a fact about how to work in this repo is not in a file, it does not
> exist. Add or update a file before you act on memory.

## Startup Workflow

Before changing code, in this order:

1. Confirm the repo root with `pwd`. It must end in `/rn-harness`.
2. Read `claude-progress.md` for prior-session handoff notes and known issues.
3. Read `feature_list.json` to see which features are `done`, `in_progress`,
   or `blocked`.
4. Read `docs/ARCHITECTURE.md` for the layer model and dependency rules.
5. Read `docs/HARNESS.md` for the working contract and definitions of done.
6. Review recent commits: `git log --oneline -10`.
7. Run `./init.sh` and wait for it to complete cleanly.
8. If the baseline (`npm run verify`) is broken, **repair the baseline first**.
   Do not start new work on a red baseline.
9. Pick the highest-priority feature whose `status` is `in_progress` or the
   next `todo` one. Work on **only that feature** until it is verified or
   explicitly blocked. (WIP = 1.)

## Routing Map

- `docs/ARCHITECTURE.md` — domain map, layer model, dependency rules
- `docs/HARNESS.md` — working contract, DoD, WIP=1, session lifecycle
- `docs/RN_PLATFORM.md` — Expo, Metro, Hermes, native modules, EAS rules
- `docs/VERIFICATION.md` — what runs in `npm run verify` and why
- `docs/UI.md` — design system, theming, accessibility, RTL
- `docs/SESSION.md` — end-of-session checklist
- `docs/WHY_HARNESS_FOR_RN.md` — why this discipline pays off for React Native
- `feature_list.json` — scope boundaries, machine-readable
- `claude-progress.md` — durable session log

## Hard Rules

- **WIP = 1.** Touch one feature at a time. Do not bundle "while I'm here"
  fixes into an unrelated feature.
- **No declaring victory without evidence.** Code inspection ≠ done. Tests must
  pass, the app must start, and the feature's verification steps from
  `feature_list.json` must each be checked.
- **Do not edit `ios/` or `android/` folders.** This project is managed
  workflow (Expo prebuild). Native changes go through `app.json`, config
  plugins, or `expo-build-properties` — see `docs/RN_PLATFORM.md`.
- **Pin behavior to versions.** Expo SDK 54 is current. When in doubt, read
  the exact versioned docs at https://docs.expo.dev/versions/v54.0.0/ before
  writing code that depends on platform APIs.
- **Do not skip Metro / type / lint failures.** Resetting caches is not a fix;
  it is a diagnosis tool. If a fix requires clearing the Metro cache, document
  *why* in `claude-progress.md`.

## Definition Of Done

A change is "done" only when **all** of the following are true:

- Target behavior is implemented and the verification steps in
  `feature_list.json` for the feature have each been performed.
- `npm run verify` passes from a clean clone (lint + typecheck + unit tests).
- The app starts via `npm run start` without red error overlays on at least
  one platform (iOS sim, Android emulator, or Web — record which).
- Docs affected by the change are updated in the same session.
- `feature_list.json` is updated: status moved to `done`, `passes: true`,
  and the matching commit SHA recorded.
- `claude-progress.md` reflects the new state and lists the next action.

## End Of Session

Before ending a session, run through `docs/SESSION.md`. The shortest version:

1. `npm run verify` — must be green or have a documented red-line waiver.
2. Update `feature_list.json` and `claude-progress.md`.
3. Commit small, coherent changes — never `git add -A` after a long session
   without reviewing the diff.
4. Run `npm run harness:clean-state` and address anything it flags.
5. Leave a one-paragraph "next action" at the top of `claude-progress.md` so
   the next session can begin without re-reading the world.
