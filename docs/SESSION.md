# docs/SESSION.md — Session lifecycle

## Continuity checklist (Lecture 05, adapted)

Before ending a session, all four must be true:

- [ ] A fresh agent can identify recent work in under five minutes
      (`git log`, `gh pr list`, `features/` are honest).
- [ ] The startup path is documented (`./init.sh` runs clean).
- [ ] Unfinished work is identified (every `features/*.json`'s
      `status` is current).
- [ ] The next best task is visible — derived from `features/` by
      listing what's `in_progress` (claim it) or `todo` (next).

If any is false, fix it before you stop.

## End-of-session steps

1. `npm run verify` — must be green.
2. Update the in-flight `features/<id>.json` you touched (status,
   `passes`, notes).
3. **Flip status to `done` *before* the merge.** Set `commitSha` to
   the latest branch tip SHA (the last implementation commit). The
   PR's merge then carries the closed feature into main as part of
   its own diff — no follow-up bookkeeping commit needed.
4. Commit, push.
5. Open / update the PR (see *Opening a PR* below).
6. `npm run harness:clean-state`.

## The close-before-merge convention

This is the harness's answer to the bookkeeping gap. Previously,
features were closed by a *follow-up* commit on `main` after the
merge — which kept getting forgotten, leaving merged features
stuck at `in_progress`.

New rule: **the last commit on the feature branch flips status to
`done`**. The PR carries that change into main as part of its diff.

```
... implementation commits ...
<last commit>  features/<id>.json: status → done, commitSha → <branch-tip>
merge to main  the merge commit just wraps this; nothing to do after
```

The `commitSha` records the implementation commit, not the merge
commit. That's actually more useful — it points at *the change*, not
at the merge wrapper. `git show <sha>` still works on main after
the merge because all branch commits land in main's history.

If a follow-up issue is discovered after merge, that's a new feature
(or `fix`), not "go back and flip the original" — the original feature
genuinely was complete at the point of flipping.

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
   `features/<id>.json`. Add a `notes` line with the failing
   command, the last 30 lines of output, and your hypothesis.
2. Commit with `wip(blocked): …`.
