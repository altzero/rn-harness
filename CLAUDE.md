@AGENTS.md

# CLAUDE.md

`@AGENTS.md` imports the operating manual. Everything in `AGENTS.md`
applies. The notes below are Claude-Code-specific.

## Before your first tool call

1. List `features/`. Pick exactly one `in_progress` or `todo`
   feature. Multiple `in_progress` is a harness violation — fix it
   before doing anything else.
2. `./init.sh`. If it exits non-zero, fix the foundation first.

## When to ask vs. act

Most decisions are already in files. Before asking the user, check:

- `docs/HARNESS.md` — working contract
- `docs/ARCHITECTURE.md` — layer rules
- `docs/RN_PLATFORM.md` — Expo / Metro / Hermes rules
- `DECISIONS.md` — what was already decided and why

If the answer isn't in any file, that's a defect — fix the missing doc
in the same session you ask the question.
