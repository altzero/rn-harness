# PROGRESS.md

> Per Lecture 05. Tiny on purpose. Decisions live in `DECISIONS.md`;
> per-branch session notes live in the PR description. This file's only
> job: tell the next session **what's the next best step**.

## Current state

- Trunk: `main` at PR #3 merge (`c8bb4c9`)
- Baseline: `npm run verify` green
- Features: `features/` directory (one JSON file per feature)

## Completed

- `harness-init` — Initial harness setup (PR #1)
- `e2e-maestro` — Maestro toolchain (PR #2; sim-side verification still
  pending — flow scaffolded, but local-sim walk hasn't been recorded)
- `harness-simplify` — Strip to lecture-prescribed minimum (PR #4)
- `ci-actions` — GitHub Actions for harness gates (PR #3)

## In progress

- `harness-features` — Restructure features to per-file form + drop
  `-NNN` (this branch)

Also open: `docs-template` (was `docs-001`) on PR #5. After this PR
merges, PR #5 needs a small rebase: rename the feature file and
update PROGRESS references.

## Known issues

- None.

## Next steps

1. Land this PR (`chore/harness-features`).
2. Rebase PR #5; rename `docs-001` → `docs-template`; move from
   `feature_list.json` to `features/docs-template.json`.
3. Pick up `ui-home` (was `ui-001`).
