@AGENTS.md

# CLAUDE.md — Claude Code entry point

The `@AGENTS.md` directive above imports the operating manual. Everything
in `AGENTS.md` applies to Claude verbatim. The notes below are Claude-Code
specific.

## Before your first tool call

1. Read `claude-progress.md` for the **Next action** block.
2. Read `feature_list.json` and pick exactly one `in_progress` or `todo`
   feature. If multiple `in_progress` features exist, that is a harness
   violation — fix it (move all but one back to `todo`) before doing
   anything else.
3. Run `./init.sh`. If it fails, fix the foundation before touching
   product code.

## When to ask, when to act

This repo's harness was designed so most decisions are already encoded in
files. Before asking the user a clarifying question, check:

- `docs/HARNESS.md` — working contract
- `docs/ARCHITECTURE.md` — layer rules
- `docs/RN_PLATFORM.md` — Expo / Metro / Hermes rules
- `docs/VERIFICATION.md` — what counts as "done"
- `docs/E2E_TESTING.md` — how to verify simulator builds

If the answer is genuinely not in any file, that itself is a defect — fix
the missing doc in the same session you ask the question.

## Why this repo has so much scaffolding

It follows [harness
engineering](https://walkinglabs.github.io/learn-harness-engineering): an
empirical discipline showing that *environment design* affects long-horizon
agent reliability more than model capability does. The five subsystems
(instructions / state / verification / scope / lifecycle) and the
file-by-file conventions are the cheapest known way to keep agents from
overreaching, under-finishing, or declaring victory too early.

See `docs/WHY_HARNESS_FOR_RN.md` for the React-Native–specific case.
