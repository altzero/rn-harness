# PROGRESS.md

> Per Lecture 05. Tiny on purpose. Decisions live in `DECISIONS.md`;
> per-branch session notes live in the PR description. This file's only
> job: tell the next session **what's the next best step**.

## Current state

- Trunk: `main` at PR #6 merge (`75ee682`)
- Baseline: `npm run verify` green
- Features: `features/` directory (one JSON file per feature)

## Completed

- `harness-init` — Initial harness setup (PR #1)
- `e2e-maestro` — Maestro toolchain scaffolded (PR #2; sim-side
  verification still pending)
- `harness-simplify` — Strip to lecture-prescribed minimum (PR #4)
- `ci-actions` — GitHub Actions for harness gates (PR #3)
- `harness-features` — Features as a directory, drop `-NNN` (PR #6)

## In progress

- `docs-template` — Position repo as a starter template (this branch)

## Known issues

- None.

## Next steps

1. Land this PR (`docs/docs-template`).
2. Pick up `ui-home` (was `ui-001`).
