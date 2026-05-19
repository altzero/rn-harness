# PROGRESS.md

> Per Lecture 05. Tiny on purpose. Decisions live in `DECISIONS.md`;
> per-branch session notes live in the PR description. This file's only
> job: tell the next session **what's the next best step**.

## Current state

- Trunk: `main` at the latest commit
- Baseline: `npm run verify` green

## Completed

- `harness-001` — Initial harness setup (PR #1, merged)
- `e2e-001` — Maestro end-to-end verification (PR #2, merged)

## In progress

- `harness-002` — Simplify harness to doc-aligned form (this branch)
- `ci-001` — GitHub Actions for harness checks (PR #3, open)

## Known issues

- None.

## Next steps

1. Land this PR (`chore/harness-002-simplify`).
2. Rebase PR #3 on top; update its `harness-ci-checks.sh` to point at
   `PROGRESS.md` instead of the deleted `claude-progress.md`.
3. Pick up `ui-001`.
