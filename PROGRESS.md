# PROGRESS.md

> Per Lecture 05. Tiny on purpose. Decisions live in `DECISIONS.md`;
> per-branch session notes live in the PR description. This file's only
> job: tell the next session **what's the next best step**.

## Current state

- Trunk: `main` at PR #4 merge
- Baseline: `npm run verify` green

## Completed

- `harness-001` — Initial harness setup (PR #1)
- `e2e-001` — Maestro end-to-end verification (PR #2)
- `harness-002` — Simplify harness to doc-aligned form (PR #4)

## In progress

- `docs-001` — Position repo as a starter template (this branch)
- `ci-001` — GitHub Actions for harness checks (PR #3, open)

## Known issues

- None.

## Next steps

1. Land PR #3 (`feat/ci-001-actions` — CI gates) so this PR's README
   line about `.github/workflows/harness.yml` is accurate on main.
2. Rebase this branch onto post-#3 main if needed; land this PR.
3. Pick up `ui-001` next.
