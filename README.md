# rn-harness

> **GitHub template.** Click **Use this template** at the top of the
> repo page to spin up a new React Native project pre-wired for the
> [harness engineering](https://walkinglabs.github.io/learn-harness-engineering)
> workflow — AI coding agents and humans on the same page from day one.

A React Native (Expo SDK 54, TypeScript, Expo Router) starter that
applies the harness-engineering course's twelve principles in concrete
form. The goal: agents and humans both finish features they pick up —
no overreach, no under-finishing, no declaring victory from code that
doesn't run.

If you are an agent (Claude, Codex, Cursor, …) opening this repo,
read [`AGENTS.md`](./AGENTS.md) and [`PROGRESS.md`](./PROGRESS.md)
first. The rest of this file is for humans.

---

## What's included

### The five subsystems (Lecture 02), wired in

| Subsystem | Lives in |
| --- | --- |
| Instructions | `AGENTS.md`, `CLAUDE.md`, `docs/*.md` |
| State | `feature_list.json`, `PROGRESS.md`, `DECISIONS.md`, `git log` |
| Verification | `npm run verify` → typecheck + lint + jest + schema |
| Scope | `feature_list.json` with `wipLimit: 1` |
| Session lifecycle | `init.sh` (start), `scripts/check-clean-state.sh` (end) |

### Out of the box

- **Expo SDK 54** managed workflow, Expo Router 6, TypeScript strict.
- **Harness scaffolding** — routing docs (`AGENTS.md`, `CLAUDE.md`),
  short `PROGRESS.md` (current state) and append-only `DECISIONS.md`
  (design log), machine-readable `feature_list.json` with a validator.
- **Initialization phase** — `./init.sh` checks Node version, installs
  deps, runs typecheck + lint + schema, tails `PROGRESS.md`. Fails
  loudly so the next session knows the foundation is broken.
- **Baseline gate** — `npm run verify` runs the same checks as `init.sh`
  plus the test suite. Run this before every commit.
- **End-of-session gate** — `npm run harness:clean-state` checks the
  working tree, baseline status, debug markers, and that
  `PROGRESS.md` has a current *Next steps* section.
- **Naming standard** — feature IDs (`<category>-<NNN>`), branch names
  (`<type>/<feature-id>-<slug>`), and commit subjects
  (`<type>(<feature-id>): …`) all carry the same identifier. Enforced
  by `scripts/feature-list-check.js`.
- **End-to-end testing** — [Maestro](https://maestro.mobile.dev) flows
  in `.maestro/`, run via `npm run e2e`. Wrapper script
  (`scripts/run-maestro.sh`) drops screenshots and JUnit reports into
  `tmp/diagnostics/` keyed by timestamp.
- **Sim/emulator helpers** — `npm run sim:ios` and `npm run sim:android`
  boot a simulator (separate from `npm run ios/android` which builds
  the app).
- **GitHub Actions CI** — `.github/workflows/harness.yml` runs two
  jobs: `static` (typecheck/lint/jest/schema + harness invariants on
  ubuntu, ~1 min, required) and `e2e-ios` (Maestro on a real
  simulator on macOS, advisory, label-gated to control runner cost).

### Conspicuously *not* included

- No `lib/` with speculative utilities. Add it when you have a real
  consumer.
- No `__tests__/` with placeholder tests. Add a test when you have
  behavior to test.
- No design system, no auth, no networking layer. The harness is
  about *how* you build; *what* you build is yours to decide.

---

## Quick start (after using the template)

```bash
nvm use 22         # any Node ≥ 20
./init.sh          # install + typecheck + lint + schema; tails PROGRESS.md
npm run verify     # baseline gate
npm run start      # i = iOS sim, a = Android emulator, w = web
```

## First things to edit

When you spin up a new repo from this template:

1. **Replace this README** with your project's description. The harness
   discipline doesn't go in your README — it's already in the docs/
   and AGENTS.md files.
2. **`app.json`** — set `name`, `slug`, `ios.bundleIdentifier`,
   `android.package`. Currently `rn-harness-scaffold` (carryover from
   `create-expo-app`).
3. **`feature_list.json`** — delete the example `ui-001` / `ui-002`
   entries (they're scaffold-shaped, not your features). Add yours.
4. **`PROGRESS.md`** — rewrite the *Next steps* section for your
   project. Clear Completed / In progress / Known issues to empty
   states.
5. **`DECISIONS.md`** — keep the format, clear the entries. Log your
   own decisions as they come up.
6. **`package.json`** — change `name` from `rn-harness`.

The scripts, docs/, and harness scaffolding stay as-is — that's the
point. Don't fork-and-customize the harness; use it as written.

## Repo layout

```
rn-harness/
├── AGENTS.md             # agents start here
├── CLAUDE.md             # @imports AGENTS.md
├── README.md             # ← replace when using as a template
├── PROGRESS.md           # next steps, known issues
├── DECISIONS.md          # append-only design log
├── feature_list.json     # scope primitive (Lecture 08)
├── init.sh               # initialization phase (Lecture 06)
├── app/                  # expo-router routes
├── components/ hooks/ constants/    # standard Expo scaffold
├── docs/
│   ├── HARNESS.md        # working contract, naming standard, DoD
│   ├── SESSION.md        # end-of-session checklist
│   ├── ARCHITECTURE.md   # folder map, layer model
│   └── RN_PLATFORM.md    # Expo / Metro / Hermes / EAS rules
├── scripts/
│   ├── verify.sh             # baseline gate
│   ├── check-clean-state.sh  # end-of-session gate
│   ├── feature-list-check.js # validator
│   ├── harness-ci-checks.sh  # CI invariants
│   ├── run-maestro.sh        # Maestro flow wrapper
│   ├── sim-ios.sh            # boot iOS simulator
│   └── sim-android.sh        # boot Android emulator
├── .maestro/             # E2E flows (Lecture 10)
└── .github/workflows/
    └── harness.yml       # static + e2e-ios CI jobs
```

## Development loop

```
1. ./init.sh                   → environment healthy
2. read PROGRESS.md            → next best step
3. pick one feature            → WIP = 1
4. implement + npm run verify  → typecheck, lint, test, schema
5. walk verification list      → in a real sim (see .maestro/)
6. flip feature → done         → status, passes, commitSha
7. commit, push, open PR       → CI runs the same gates
8. npm run harness:clean-state → leave a clean state
```

## Further reading

- [Learn Harness Engineering](https://walkinglabs.github.io/learn-harness-engineering) — the course this repo is built around
- [Expo SDK 54 docs](https://docs.expo.dev/versions/v54.0.0/)
- [Maestro](https://maestro.mobile.dev) for mobile end-to-end testing
