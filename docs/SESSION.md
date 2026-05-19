# docs/SESSION.md — Session lifecycle

## Continuity checklist (Lecture 05)

Before ending a session, all four must be true:

- [ ] A fresh agent can identify recent work in under five minutes
      (`git log` + `gh pr list` are honest).
- [ ] The startup path is documented (`./init.sh` runs clean).
- [ ] Unfinished work is identified (`feature_list.json[].status`
      is current).
- [ ] The next best task is visible without reading chat logs
      (`PROGRESS.md` → *Next steps*).

If any is false, fix it before you stop.

## End-of-session steps

1. `npm run verify` — must be green.
2. Update `feature_list.json` for any features you touched (status,
   `passes`, `commitSha`).
3. Update `PROGRESS.md` *Next steps* so the next session can begin
   cold.
4. Append any non-obvious decisions to `DECISIONS.md`.
5. Commit; push.
6. **Open a PR** if the branch is reviewable. Title plain English
   (no feature-ID prefix — that goes in the body). The body
   carries the per-session detail that used to live in a Sessions
   log; once the PR is open, you don't also need to write that log
   elsewhere.
7. Run `npm run harness:clean-state`.

## Opening a PR — body template

```
<one-line context>

## Summary
- bullets on what changed

## Verification status
- what's been run locally / in CI
- what's left for the next session

## To test locally
- exact commands

## Merge order (if stacked)
- upstream / downstream PRs
```

## If you stop mid-feature with the baseline red

1. Move the in-flight feature's `status` to `blocked` in
   `feature_list.json`.
2. Add a *Known issues* line in `PROGRESS.md` with the failing
   command, the last 30 lines of output, and your hypothesis.
3. Commit with `wip(blocked): …`.
