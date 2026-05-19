# docs/VERIFICATION.md — What `npm run verify` actually does

`npm run verify` is the **baseline gate**. If it is red, do not write new
code; repair the baseline first (per Lecture 06 — foundation before walls).

## What it runs, in order

`scripts/verify.sh` runs:

1. **Typecheck** — `tsc --noEmit`. Catches type errors and module-resolution
   problems. Fast, runs first because it has the highest signal-to-noise.
2. **Lint** — `expo lint`. Catches layer-boundary violations, dead code,
   import cycles.
3. **Unit tests** — `jest --passWithNoTests`. Runs in `jest-expo`'s RN
   environment. `--passWithNoTests` because early on we may have features
   without tests yet, but the moment a feature ships with `passes: true`,
   it should have one.
4. **Feature list schema** — `node scripts/feature-list-check.js`.
   Validates `feature_list.json`.

If any step fails, `verify.sh` exits non-zero immediately. **No "summary at
the end."** The point of the gate is to push you toward the failing step.

## What it does NOT run

- The app on a device/simulator. That's `npm run start`. End-to-end
  verification of a feature is done by following its `verification` list,
  not by `npm run verify`.
- Detox or Maestro flows. Those are separate (`npm run e2e`, not yet
  scaffolded) because they require a device.
- EAS builds. Those are gated by `eas build` directly.

## When to skip a check (and how)

You don't. If a check is wrong, fix it. If a check is too slow, profile
and fix it. If a check is blocking a hotfix, the hotfix is also a fix to
the check — same PR, same commit. The harness rule is: **`verify` is
green or nothing else happens.**

The single exception: a `.harness-waiver` file at the repo root can list a
specific check to skip with a reason and an expiry date. `verify.sh` reads
this and prints a loud warning if any waiver is active. Waivers without an
expiry date in the future are ignored (i.e., treated as expired).

## Wiring to the feature lifecycle

- A feature cannot move to `in_progress` if `verify` is red on the current
  HEAD.
- A feature cannot move to `done` unless `verify` is green AND its
  `verification` list has been performed.
- `passes: true` in `feature_list.json` records that the verification list
  was performed; the commit SHA in `commitSha` records the state at which
  it passed.
