# rn-harness

A React Native (Expo SDK 54, TypeScript, Expo Router) starter wired for
**harness engineering** — a discipline for building reliable environments
around AI coding agents, originally codified by
[Walking Labs' *Learn Harness Engineering* course](https://walkinglabs.github.io/learn-harness-engineering).

If you are a coding agent (Claude, Codex, Cursor, etc.) opening this repo,
**read [`AGENTS.md`](./AGENTS.md) and [`claude-progress.md`](./claude-progress.md) first**.
The rest of this README is for humans.

---

## TL;DR

This repo demonstrates a simple but opinionated way to apply the twelve
harness-engineering principles to a real React Native project. The five
subsystems (instructions, state, verification, scope, session lifecycle)
each have a concrete home in the repo:

| Subsystem | Where it lives |
| --- | --- |
| Instructions | `AGENTS.md` + topic files under `docs/` |
| State | `feature_list.json`, `claude-progress.md`, `git log` |
| Verification | `npm run verify` → `scripts/verify.sh` |
| Scope | `feature_list.json` with `wipLimit: 1` |
| Session lifecycle | `init.sh` (start), `scripts/check-clean-state.sh` (end) |

---

## Quick start (humans)

```bash
# 1. Install Node 20+ (Expo SDK 54 requires it)
nvm use 20

# 2. Initialize — verifies environment, installs deps, runs typecheck + lint
./init.sh

# 3. Confirm the baseline is green
npm run verify

# 4. Start the app
npm run start
# then press i (iOS sim), a (Android emulator), or w (web)
```

---

## Quick start (agents)

```bash
pwd                       # confirm you're in /rn-harness
cat claude-progress.md    # read the Next action block
cat feature_list.json     # pick one in_progress or todo feature
./init.sh                 # initialize environment
npm run verify            # confirm baseline green
# work on EXACTLY ONE feature until it meets DoD in AGENTS.md
npm run harness:clean-state   # before you stop
```

---

## What's in this repo

```
rn-harness/
├── AGENTS.md                 # ← agents start here
├── CLAUDE.md                 # ← Claude-specific entry (imports AGENTS.md)
├── README.md                 # ← humans start here
├── init.sh                   # initialization phase (lecture 06)
├── feature_list.json         # machine-readable scope (lecture 08)
├── claude-progress.md        # session continuity log (lecture 05)
├── app/                      # expo-router routes
├── components/               # shared UI primitives
├── lib/                      # pure-TS utilities (no react)
├── hooks/ constants/         # standard expo scaffold
├── docs/
│   ├── HARNESS.md            # working contract, DoD, WIP=1
│   ├── ARCHITECTURE.md       # layer model
│   ├── RN_PLATFORM.md        # Expo / Metro / Hermes rules
│   ├── VERIFICATION.md       # what `npm run verify` checks
│   ├── E2E_TESTING.md        # how to test simulator builds
│   ├── UI.md                 # theming / a11y / RTL
│   ├── SESSION.md            # end-of-session checklist
│   └── WHY_HARNESS_FOR_RN.md # RN-specific case for harness engineering
└── scripts/
    ├── verify.sh             # baseline gate
    ├── check-clean-state.sh  # end-of-session gate
    ├── feature-list-check.js # feature_list.json validator
    └── feature_list.schema.json
```

---

## The twelve principles, applied here

| # | Principle (lecture title) | Where in this repo |
| --- | --- | --- |
| 01 | Strong models don't mean reliable execution | Why this repo exists. |
| 02 | A harness is five subsystems, not a prompt | `docs/HARNESS.md` |
| 03 | The repository is the system of record | Every rule is in a file, not in chat. |
| 04 | Split instructions across files | `AGENTS.md` is a router; `docs/*.md` are leaves. |
| 05 | Keep context alive across sessions | `claude-progress.md` |
| 06 | Initialize before every session | `init.sh` |
| 07 | Draw clear task boundaries (WIP=1) | `feature_list.json` `wipLimit: 1`, enforced by `scripts/feature-list-check.js` |
| 08 | Feature lists are harness primitives | `feature_list.json` with `verification[]` per feature |
| 09 | Don't declare victory too early | `passes: true` requires the verification list to have run; commit SHA recorded |
| 10 | E2E testing changes results | `docs/E2E_TESTING.md`; simulator build steps per feature |
| 11 | Observability inside the harness | `lib/log.ts`, structured `[ok]/[fail]` lines in scripts |
| 12 | Every session must leave a clean state | `scripts/check-clean-state.sh`, `docs/SESSION.md` |

---

## The development loop in practice

```
┌──────────────────────────────────────────────────────────────┐
│                    START OF SESSION                          │
│  1. pwd  → confirm repo root                                 │
│  2. read claude-progress.md → resume state                   │
│  3. read feature_list.json → know what's in flight           │
│  4. ./init.sh → environment healthy?                         │
│  5. npm run verify → baseline green?                         │
└──────────────────────────────────────────────────────────────┘
                          │
                          ▼
┌──────────────────────────────────────────────────────────────┐
│                    PICK ONE FEATURE                          │
│  Highest-priority in_progress, else first todo.              │
│  Move status → in_progress, set owner.                       │
│  WIP=1 — do NOT pick a second feature.                       │
└──────────────────────────────────────────────────────────────┘
                          │
                          ▼
┌──────────────────────────────────────────────────────────────┐
│                IMPLEMENT  +  VERIFY                          │
│  • write code                                                │
│  • npm run verify  (typecheck, lint, unit, schema)           │
│  • walk the feature's verification[] in a real sim/emu       │
│    (see docs/E2E_TESTING.md)                                 │
└──────────────────────────────────────────────────────────────┘
                          │
                          ▼
┌──────────────────────────────────────────────────────────────┐
│                       MARK DONE                              │
│  • feature_list.json: status=done, passes=true, commitSha    │
│  • update affected docs in same commit                       │
│  • update claude-progress.md "Next action" block             │
└──────────────────────────────────────────────────────────────┘
                          │
                          ▼
┌──────────────────────────────────────────────────────────────┐
│                   END OF SESSION                             │
│  • npm run verify  → green                                   │
│  • npm run harness:clean-state                               │
│  • append "Session YYYY-MM-DD" entry to claude-progress.md   │
│  • commit with feature id in the message                     │
└──────────────────────────────────────────────────────────────┘
```

---

## Why this matters for React Native specifically

React Native has more silent-failure surface area than most stacks: Metro
caches, Hermes vs JSC differences, native module ABI drift, Expo SDK pinning,
iOS/Android platform splits, simulator vs device behavior, EAS build state.
Each is a place where an agent (or human) can convince themselves a change
works when it doesn't.

The harness exists to make those silent failures loud and recoverable. See
[`docs/WHY_HARNESS_FOR_RN.md`](./docs/WHY_HARNESS_FOR_RN.md) for concrete
examples.

For how to actually verify a feature in a simulator — including
`xcrun simctl`, `adb`, Detox, Maestro, and EAS dev builds — see
[`docs/E2E_TESTING.md`](./docs/E2E_TESTING.md).

---

## Further reading

- *Learn Harness Engineering* (the course this repo is built around):
  https://walkinglabs.github.io/learn-harness-engineering
- Expo SDK 54 docs (versioned — read these, not the unversioned ones):
  https://docs.expo.dev/versions/v54.0.0/
- React Native architecture overview:
  https://reactnative.dev/docs/the-new-architecture/landing-page
