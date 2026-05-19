# rn-harness

A React Native (Expo SDK 54, TypeScript) starter wired for [harness
engineering](https://walkinglabs.github.io/learn-harness-engineering) —
the discipline of building a reliable environment around AI coding
agents.

Agents: read [`AGENTS.md`](./AGENTS.md) and [`PROGRESS.md`](./PROGRESS.md)
first. The rest is for humans.

## Five subsystems

| Subsystem | Lives in |
| --- | --- |
| Instructions | `AGENTS.md` + `docs/*.md` |
| State | `feature_list.json`, `PROGRESS.md`, `DECISIONS.md`, `git log` |
| Verification | `npm run verify` (typecheck + lint + jest + schema) |
| Scope | `feature_list.json` with `wipLimit: 1` |
| Session lifecycle | `init.sh` (start), `scripts/check-clean-state.sh` (end) |

## Quick start

```bash
nvm use 22         # or any Node >= 20
./init.sh          # install + typecheck + lint + schema; tails PROGRESS.md
npm run verify     # baseline gate
npm run start      # i = iOS sim, a = Android emulator, w = web
```

## Repo layout

```
rn-harness/
├── AGENTS.md             # agents start here
├── CLAUDE.md             # @imports AGENTS.md
├── README.md             # humans start here
├── PROGRESS.md           # next steps, known issues (small)
├── DECISIONS.md          # append-only design log
├── feature_list.json     # scope (lecture 08)
├── init.sh               # initialization (lecture 06)
├── app/                  # expo-router routes
├── components/ hooks/ constants/   # standard Expo scaffold
├── docs/
│   ├── HARNESS.md        # working contract, naming standard, DoD
│   ├── SESSION.md        # end-of-session checklist
│   ├── ARCHITECTURE.md   # folder map, layer model
│   └── RN_PLATFORM.md    # Expo / Metro / Hermes / EAS rules
├── scripts/
│   ├── verify.sh             # baseline gate
│   ├── check-clean-state.sh  # end-of-session gate
│   ├── feature-list-check.js # schema + WIP validator
│   ├── run-maestro.sh        # E2E flow wrapper
│   ├── sim-ios.sh            # boot iOS simulator
│   └── sim-android.sh        # boot Android emulator
└── .maestro/             # E2E flows (lecture 10)
```

## Development loop

```
1. ./init.sh                   → environment healthy
2. read PROGRESS.md            → next best step
3. pick one feature            → WIP = 1
4. implement + npm run verify  → typecheck, lint, test, schema
5. walk verification list      → in a real sim (see .maestro/)
6. flip feature → done         → status, passes, commitSha
7. commit, push, open PR       → see docs/SESSION.md
8. npm run harness:clean-state → leave a clean state
```

## Further reading

- The course this repo is built around:
  https://walkinglabs.github.io/learn-harness-engineering
- Expo SDK 54: https://docs.expo.dev/versions/v54.0.0/
