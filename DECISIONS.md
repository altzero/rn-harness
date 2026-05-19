# DECISIONS.md

> Append-only log of non-obvious project decisions, per Lecture 05.
> Format: `## YYYY-MM-DD — short title` then a few lines of *what / why /
> rejected alternative / constraints*. Newest at the bottom.

## 2026-05-19 — Expo (managed) over bare React Native CLI

- **What:** project scaffolded with `create-expo-app`; managed workflow,
  no `ios/`/`android/` in git.
- **Why:** Expo SDK 54 covers our needs; EAS for builds; avoids native
  drift between agent sessions (which is exactly what harness
  engineering exists to prevent).
- **Rejected:** bare RN CLI — more native surface area, more places for
  silent drift.
- **Constraint:** native modules need a config plugin or a dev build;
  no direct edits to native dirs.

## 2026-05-19 — Expo Router for file-based navigation

- **What:** routes live in `app/`, navigated by file path.
- **Why:** matches the Next.js mental model most agents already have.
- **Rejected:** React Navigation only — works, but more boilerplate.

## 2026-05-19 — Maestro for E2E (not Detox, not Playwright)

- **What:** Maestro is the e2e tool wired into `feature_list.json`
  verification lists.
- **Why:** single-binary YAML runner; flows are trivial for agents to
  author; output (logs + screenshots + JUnit XML) plugs straight into
  the harness.
- **Rejected:** Playwright (web-only — no Hermes coverage); Detox (more
  power but heavy per-feature wiring).

## 2026-05-19 — Sim boot helpers separate from `npm run ios/android`

- **What:** `scripts/sim-ios.sh` and `scripts/sim-android.sh` boot the
  simulator only; `npm run ios/android` does build+install+launch.
- **Why:** booting and building are different concerns. Agents should
  be able to warm a sim once and run multiple flows against it.

## 2026-05-19 — Naming standard: `<category>-<NNN>` everywhere

- **What:** feature IDs in `feature_list.json`, branch names
  (`<type>/<feature-id>-<slug>`), and commit subjects
  (`<type>(<feature-id>): …`) all carry the same ID.
- **Why:** a single `git log --grep='(ui-002)'` returns the full story.
  Drift between forms of state erodes the "repo is system of record"
  principle (Lecture 03).
- **Enforced:** `scripts/feature-list-check.js` validates IDs against
  `^[a-z][a-z0-9]*(-[a-z][a-z0-9]*)*-\d{3}$`.

## 2026-05-19 — Removed speculative testing-library deps

- **What:** dropped `@testing-library/jest-native` and
  `@testing-library/react-native` from `devDependencies`.
- **Why:** added for `ui-001`/`ui-002` render tests that don't exist
  yet; ERESOLVE'd against React 19.1 (Expo SDK 54). Re-add at the right
  version when the consuming feature starts.

## 2026-05-19 — Split `claude-progress.md` into PROGRESS.md + DECISIONS.md

- **What:** the bloated single-file progress log is gone; replaced with
  a ~25-line `PROGRESS.md` and this append-only `DECISIONS.md`.
- **Why:** Lecture 05's actual prescription is two files. The combined
  file caused a conflict on every parallel-branch merge because
  *Current State* / *Next Action* / *Sessions log* / *Decisions* all
  changed on every branch. Decisions are append-only by date — they
  almost never conflict when separated. Per-branch session notes belong
  in the PR description, not in a shared file.
- **Rejected:** keeping one file; one file per branch (fragments state).
