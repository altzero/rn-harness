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

## 2026-05-20 — Features as a directory; drop the `-NNN` suffix

- **What:** Replaced `feature_list.json` (single shared array) with a
  `features/` directory of one JSON file per feature. Feature IDs are
  now `<category>-<slug>` (e.g. `ui-home`, `ci-actions`) — no
  zero-padded number.
- **Why:** Every parallel-branch PR was conflicting on the shared
  `features` array. Per-file means two branches that add different
  features touch different files (no collision). The `-NNN` suffix
  carried no semantic value and actively created contention (two
  branches both wanting `ui-003`); a meaningful slug is unique by
  intent.
- **Rejected:** keeping JSON-in-one-file (conflict source unchanged);
  YAML files (adds js-yaml runtime dep for no win); status in PR
  labels (couples to GitHub-as-tool). JSON-in-a-directory keeps
  primitives in the repo (Lecture 03) and uses tooling already in
  the project.
- **Trade-off:** WIP=1 is checked per branch view. Two branches each
  marking a different feature `in_progress` and both merging to main
  creates a transient WIP=2 — resolved manually at the second merge
  by demoting one to `todo` or `done`. Accept this; the alternative
  (mid-branch validators that see across PRs) is too magic for the
  benefit.

## 2026-05-20 — PROGRESS.md is human content only; status lives in features/

- **What:** Removed the *Completed* and *In progress* sections from
  PROGRESS.md. PROGRESS.md now carries only: a one-line *Current
  state*, *Known issues*, and *Next steps* — the parts that aren't
  derivable from `features/*.json` or git history.
- **Why:** After every PR merge, PROGRESS.md's *Completed* / *In
  progress* sections were stale until someone (us) hand-edited them.
  Same fact in two places → one place rots. The user pointed this out
  directly after PR #7's docs-template ended up listed as "In progress"
  on main even though the PR had closed.
- **Rejected:** auto-update via GitHub Action on push-to-main (works
  but adds a bot commit per merge + a write-token requirement +
  another loop to debug); pre-merge gate requiring status-flip in the
  PR (chicken-and-egg with merge commit SHA — can't know it before
  merging).
- **Trade-off:** anyone wanting "what's done" / "what's in progress"
  reads `features/` directly (or runs `npm run harness:features` for
  the one-line summary). The *Next steps* section can still be briefly
  stale right after a merge — but it's genuinely human content, and the
  next session refreshes it as the first thing they do. Self-healing
  in a way *Completed* / *In progress* never were.
