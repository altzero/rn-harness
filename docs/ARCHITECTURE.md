# docs/ARCHITECTURE.md

The technical map of the repo. Update this in the same commit as any change
that crosses a layer boundary.

## Stack

- **Expo SDK 54** with managed workflow.
- **Expo Router 6** for file-based navigation under `app/`.
- **React Native 0.81** on **Hermes**.
- **TypeScript** strict mode (see `tsconfig.json`).
- **Jest + jest-expo** for unit/component tests.
- **ESLint via `expo lint`** for static checks.

## Folder map

```
rn-harness/
├── AGENTS.md                 # routing into the harness
├── CLAUDE.md                 # Claude-specific entry point
├── README.md                 # human-facing overview
├── init.sh                   # initialization phase
├── feature_list.json         # scope primitive
├── claude-progress.md        # session log
├── app/                      # expo-router routes (THE app entry)
│   ├── _layout.tsx           # root stack
│   └── (tabs)/
│       ├── _layout.tsx       # tab navigator
│       ├── index.tsx         # home tab
│       └── features.tsx      # feature list tab (per ui-002)
├── components/               # cross-route presentational components
├── lib/                      # pure TS (no react), data + utilities
│   ├── log.ts                # single logger
│   └── feature-list.ts       # read & summarise feature_list.json
├── hooks/                    # custom hooks (already scaffolded)
├── constants/                # theme tokens (already scaffolded)
├── docs/                     # topic-specific instruction files
├── scripts/                  # bash + node scripts used by the harness
│   ├── verify.sh
│   ├── feature-list-check.js
│   └── check-clean-state.sh
└── __tests__/                # unit + snapshot tests
```

## Layer model

Three layers, with one-way dependencies:

1. **lib/** — pure TypeScript, no React, no react-native. Easy to unit test
   without a renderer.
2. **components/** and **hooks/** — UI primitives, depend on `lib/` and
   `react-native`. No knowledge of routes.
3. **app/** — routes. Depend on `components/`, `hooks/`, and `lib/`. The only
   layer that imports `expo-router`.

Hard rules:

- `lib/` MUST NOT import from `components/`, `app/`, `hooks/`, or `react-native`.
  If you find a reason to break this, write a decision-log entry first.
- `components/` MUST NOT import from `app/`.
- Tests in `__tests__/` may import from any layer.

## Why these specific layers

- `lib/` exists so `feature_list.json` parsing, log shaping, and other
  non-UI logic can be tested without spinning up the React renderer. This
  matters: RN tests that depend on the renderer are 10–100× slower than pure
  TS tests, and that gap compounds across an agent's iteration loop.
- The router (`app/`) is intentionally thin. Routes wire data sources to
  components; they don't contain business logic. This means a feature can
  usually be implemented by editing one route, one component, and one lib
  module — which keeps WIP=1 honest.

## Dependency rules (auto-checkable)

`npm run verify` runs lint, which is configured (via `eslint-config-expo`)
to flag the layer violations above. If you find a way around the linter,
fix the linter — don't add the import.

## What lives where (decision examples)

- "Parse feature_list.json" → `lib/feature-list.ts`. Pure.
- "Pill component that renders a status with a color" → `components/StatusPill.tsx`.
- "Tab that renders the feature list" → `app/(tabs)/features.tsx`.
- "Hook that subscribes to feature changes" → `hooks/use-features.ts`.
