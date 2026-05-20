# .maestro/

[Maestro](https://maestro.mobile.dev) flows for end-to-end verification of
features in `features/`. Each flow corresponds to one or more
verification steps in a feature's JSON file.

## Why Maestro (and not Detox/Playwright)

- **Playwright** drives the **web build only** (`npm run web`). Useful as a
  fast first pass, but does not exercise Hermes, native modules, or
  platform-specific code paths. See `scripts/e2e-web.sh` (TODO) if/when
  we add it.
- **Detox** is more powerful but requires per-platform native setup and
  significant per-feature wiring. It's the right choice for production
  apps with rich gesture flows; overkill for early-stage harness work.
- **Maestro** is YAML, runs from a single binary, and produces structured
  output and screenshots an agent can read back. It is the cheapest way
  to satisfy a feature's verification list with a real platform run.

## Layout

```
.maestro/
├── README.md              # this file
├── config.yaml            # shared Maestro config (appId override, etc.)
└── flows/
    └── home.yaml          # sample flow — verifies the home tab boots
```

## Running

```bash
# from the repo root
npm run e2e:ios            # runs flows/home.yaml on a booted iOS sim
npm run e2e:android        # same on a running Android emulator

# or directly:
bash scripts/run-maestro.sh .maestro/flows/home.yaml
```

`scripts/run-maestro.sh` is the harness wrapper. It:

1. Checks `maestro` is installed (prints the install command if not).
2. Checks a simulator is booted (prints the boot command if not).
3. Runs the flow with structured `[ok]/[fail]` output.
4. Drops the run's artifacts (logs, screenshots) in `tmp/diagnostics/`
   keyed by timestamp + flow name, so the agent has a single place to
   grep when something fails.

## Authoring a new flow

1. Decide which feature in `features/` this flow verifies. The
   filename should be `<feature-id>.yaml`.
2. The first non-comment line **must** set `appId`. Use the project-level
   default (see `config.yaml`) unless this flow targets a different
   surface (e.g., Expo Go).
3. Every flow should end with `takeScreenshot:` so the artifact is in
   `tmp/diagnostics/` for the agent to read back.
4. Add the flow's invocation to the feature's `verification[]` array.

## appId conventions

| Surface | appId |
| --- | --- |
| Expo Go (default dev) | `host.exp.exponent` |
| EAS dev build (this project) | derived from `ios.bundleIdentifier` in `app.json` |
| EAS production build | same as dev build |

Override per-run with `APP_ID=… npm run e2e:ios` if needed.
