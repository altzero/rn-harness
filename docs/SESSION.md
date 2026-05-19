# docs/SESSION.md — End-of-session checklist

Run through this every time you stop, even if you're "just stepping away."
A session that ends cleanly costs the next session 60 seconds to resume; a
session that ends in the middle of work costs 30 minutes of archaeology.

## The checklist

- [ ] **Baseline is green.** `npm run verify` exits 0. If it is red, either
      fix it or open an entry in `claude-progress.md` Known Issues with the
      exact failing output and the next debugging step.
- [ ] **Working tree explained.** Either commit it, or each modified file is
      mentioned in `claude-progress.md` with a one-line reason.
- [ ] **Feature state is current.** `feature_list.json` reflects reality. If
      you finished the feature: `status: "done"`, `passes: true`, commit SHA
      filled in.
- [ ] **Progress log is current.** `claude-progress.md`:
        - The **Next action** block at the top is rewritten to point at the
          actual next thing.
        - A new "Session YYYY-MM-DD" entry is appended with what you did,
          verify result, and what to watch out for.
- [ ] **Clean state script passes.** `npm run harness:clean-state`.
- [ ] **No surprise edits.** Run `git status` and look at the list. Did you
      change something you didn't intend? Stash or revert it.
- [ ] **No stray debug code.** `console.log`, `debugger`, `.only`, `xit`,
      `// FIXME` without a feature_list.json entry. The clean-state script
      catches most of these.
- [ ] **Tmp files clean.** `tmp/` should contain only diagnostics referenced
      from a progress entry.

## When you've broken the build

If you have to stop mid-feature with the baseline red, that is a *bad* state
but a *recoverable* one. Required steps:

1. Set the in-progress feature's `status` to `blocked` in
   `feature_list.json`.
2. In `claude-progress.md` under Known Issues, write a paragraph with:
   the exact failing command, the last 30 lines of output, your hypothesis,
   and the next step you would have taken.
3. Commit with a message starting `wip(blocked): …` so the SHA is
   discoverable.

The next session reads this and starts at step "next step you would have
taken," not at "what just happened?"
