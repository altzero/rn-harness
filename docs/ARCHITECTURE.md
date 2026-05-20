# docs/ARCHITECTURE.md

The technical map of the repo.

## Stack

- Expo SDK 54, managed workflow
- Expo Router 6 (file-based routing under `app/`)
- React Native 0.81 on Hermes
- TypeScript strict
- Jest + jest-expo
- ESLint via `expo lint`

## Folder map

```
rn-harness/
├── AGENTS.md            # router into harness docs
├── CLAUDE.md            # Claude entry (imports AGENTS.md)
├── README.md            # human-facing overview
├── DECISIONS.md         # append-only design log
├── features/            # one JSON file per feature (status, verification)
├── init.sh              # initialization phase
├── app/                 # expo-router routes
├── components/          # presentational components
├── hooks/               # custom hooks
├── constants/           # theme tokens
├── docs/                # topic instructions
├── scripts/             # harness scripts (verify, sim, maestro, …)
└── .maestro/            # E2E flows
```

## Layer model

Two layers with one-way dependencies (pure-TS `lib/` layer is removed
until a feature needs it):

1. **components/** + **hooks/** — UI primitives. No knowledge of routes.
2. **app/** — routes. Depends on components/hooks. Only layer that
   imports `expo-router`.

When a feature needs non-UI logic (e.g. reading `features/*.json` at
build time for `ui-001`), reintroduce `lib/` as a pure-TS module — but
not before. Speculative scaffolding violates the "no hypothetical
future requirements" rule.

## Dependency rules

- `components/` MUST NOT import from `app/`. ESLint flags it.
- If you add a `lib/`, it MUST NOT import from `components/`, `hooks/`,
  `app/`, or `react-native`.
