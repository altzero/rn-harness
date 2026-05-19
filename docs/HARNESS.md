# docs/HARNESS.md — Working contract

This document is the binding agreement between humans and agents working in
this repo. It is the long form of the hard rules in `AGENTS.md`.

It is grounded in the twelve lectures of
[Learn Harness Engineering](https://walkinglabs.github.io/learn-harness-engineering).
Each rule below cites the lecture it is downstream of so future you can
re-derive it from first principles.

## The five subsystems (Lecture 02)

A harness is *not* a prompt. It is five subsystems that surround the model:

| Subsystem | Where it lives in this repo |
| --- | --- |
| **Instructions** | `AGENTS.md`, `CLAUDE.md`, `docs/*.md` |
| **State** | `feature_list.json`, `claude-progress.md`, `git log` |
| **Verification** | `npm run verify`, `init.sh`, per-feature checklists |
| **Scope** | `feature_list.json` (WIP=1), Definition of Done |
| **Session lifecycle** | `init.sh` (start), `docs/SESSION.md` (end) |

If you change *how* this repo operates, you are editing one of these five
subsystems. Identify which one before you start.

## The repository is the system of record (Lecture 03)

If a fact about how to work in this repo is not in a file, it does not exist.
This includes:

- "The CI is currently flaky on Android" — write it in `claude-progress.md`
  under Known Issues.
- "We tried `react-native-mmkv` and it crashed on Android emulator x86_64" —
  write it in `docs/RN_PLATFORM.md` under "Native modules we considered."
- "The reason we don't use `useEffect` for navigation guards" — write it in
  `docs/ARCHITECTURE.md`.

ACID for agent state:
- **Atomic** — a feature transition (`todo` → `in_progress` → `done`) is one
  commit, not a half-edited `feature_list.json`.
- **Consistent** — `claude-progress.md` and `feature_list.json` agree.
- **Isolated** — WIP=1; one in-flight feature.
- **Durable** — state survives session end. Memory does not.

## Split instructions across files (Lecture 04)

`AGENTS.md` is a **router**, not a manual. It points at topic-specific docs:
`ARCHITECTURE.md`, `RN_PLATFORM.md`, `VERIFICATION.md`, `UI.md`, `SESSION.md`,
`WHY_HARNESS_FOR_RN.md`. Keep `AGENTS.md` under ~150 lines. When it grows,
extract a new topic doc.

A monolithic AGENTS.md fails because:
- Agents skim. They miss rules buried at line 800.
- Edits collide. Two changes touch the same file unnecessarily.
- Context window pressure — every session reads it cold.

## Keep context alive across sessions (Lecture 05)

`claude-progress.md` is the journal. Append, don't rewrite. Every session
should:

- Start by reading the **Next action** block at the top.
- End by overwriting the Next action block and appending a `Session
  YYYY-MM-DD` entry under a "Sessions" section.

If you can't pick up where you left off in 60 seconds of reading, the handoff
is bad. Fix the handoff before fixing the code.

## Initialize before every session (Lecture 06)

`./init.sh` is the foundation phase. It verifies the environment, not the
product. It is idempotent. It should be the **first** thing run after
reading state.

If `./init.sh` exits non-zero, **do not** start product work. Fix the
foundation first. Mixing foundation repair and feature work is how
sessions silently destroy hours.

## WIP = 1 (Lecture 07)

Attention is finite. Touch one feature at a time. The temptation to "while
I'm in here, also fix..." is the single biggest cause of overreach. If you
notice unrelated debt:

1. Note it in `claude-progress.md` under "Decisions log" or a new entry in
   `feature_list.json` with status `todo`.
2. Stay on the current feature.

Multiple `in_progress` items is a bug in the agent's behavior, not a
feature of the workflow.

## Feature lists as harness primitives (Lecture 08)

`feature_list.json` is **machine-readable scope**. It is not a roadmap.
Every entry has:

- `id` — stable, used in commit messages.
- `title` — human label.
- `verification` — the exact steps that prove "done." If you can't write
  these, the feature is not yet ready to be picked up.
- `status` — one of `todo`, `in_progress`, `blocked`, `done`.
- `passes` — boolean, set to `true` only after verification has actually run.

`scripts/feature-list-check.js` validates this on every `init.sh`.

## Don't declare victory too early (Lecture 09)

A feature is `done` only when **every** item in its `verification` list has
been performed. Code inspection is not verification. "It compiles" is not
verification. "The unit test I just wrote passes" is not verification unless
it actually exercises the user-visible behavior.

The cheapest way to lie to yourself is to mark `passes: true` without
running the list. The verification list exists *because* models declare
victory early.

## End-to-end testing changes the result (Lecture 10)

In React Native, "end-to-end" means: the bundle builds, the app launches in
a simulator or emulator (or web), the screen renders without red overlays,
and the verification steps from `feature_list.json` happen in that running
app. Snapshot tests in Jest are not a substitute — they verify the render
tree, not that Hermes can execute the bundle.

For this repo:
- Minimum bar: app launches via `npm run start` on at least one platform.
- Preferred: a Detox or Maestro flow exercises the verification list.
- Either way: record which platform was used in the feature's commit.

## Observability inside the harness (Lecture 11)

When something fails, the agent must be able to **see** why without asking
the user. This means:

- `init.sh` and `scripts/verify.sh` print structured `[ok] / [fail]`
  lines so the cause is obvious from the last 30 lines of output.
- Logs from the running app go through a single logger (see
  `lib/log.ts`) so the agent can grep one place.
- Crash artifacts (Metro red boxes, Hermes traces) are dropped in
  `tmp/diagnostics/` with a timestamp, not paste-bombed into chat.

## Leave a clean state (Lecture 12)

Run `npm run harness:clean-state` before ending a session. It checks:

- Working tree clean or every change explained in `claude-progress.md`.
- `npm run verify` green.
- `feature_list.json` and `claude-progress.md` consistent.
- No stray `console.log` / `.only` / `xit` in committed code.
- `Next action` block in `claude-progress.md` is current.

A session that ends red, with no handoff, costs the next session 30+
minutes of archaeology. A session that ends clean costs the next session 60
seconds.
