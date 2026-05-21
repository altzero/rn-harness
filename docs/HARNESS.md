# docs/HARNESS.md — Working contract

Grounded in [Learn Harness Engineering](https://walkinglabs.github.io/learn-harness-engineering).
The lecture source is the canonical reference; this doc is the project's
short adaptation.

## Five subsystems (Lecture 02)

| Subsystem | Lives in |
| --- | --- |
| Instructions | `AGENTS.md`, `CLAUDE.md`, `docs/*.md` |
| State | `features/*.json`, `DECISIONS.md`, `git log` |
| Verification | `npm run verify`, `init.sh`, per-feature verification lists |
| Scope | `features/` directory (one file per feature), WIP=1 |
| Session lifecycle | `init.sh` (start), `docs/SESSION.md` (end) |

## Working rules

1. **WIP = 1.** One in-flight feature per branch. Drive-by debt becomes
   a new file in `features/`, not a side-edit. (Lecture 07)
2. **Repo is the system of record.** If a fact isn't in a file, it
   doesn't exist. (Lecture 03)
3. **Verification is what makes "done" real.** A feature is `done`
   only when its `verification[]` items have been performed and
   `npm run verify` is green. Code inspection doesn't count.
   (Lecture 09)
4. **Initialize before every session.** Run `./init.sh`. If the
   baseline is red, fix the foundation before touching new code.
   (Lecture 06)
5. **Leave a clean state.** PR opened with the in-flight feature
   already flipped to `done` in its last commit, verify green.
   (Lecture 12)

## Naming standard

The feature ID is the load-bearing identifier across all three forms
of state. It is a meaningful slug, not a sequence number — no `-NNN`
suffix.

| Artefact | Format | Example |
| --- | --- | --- |
| Feature ID (`features/<id>.json`) | `<category>-<slug>` | `ui-home`, `e2e-maestro`, `ci-actions` |
| Branch name | `<type>/<feature-id>` | `feat/ui-home`, `chore/harness-simplify` |
| Commit subject | `<type>(<feature-id>): <subject>` | `feat(e2e-maestro): scaffold flows …` |

- `<category>` is a stable lowercase segment (`ui`, `e2e`, `ci`,
  `harness`, `docs`, …). Pick from existing categories in `features/`
  or add a new one in a dedicated commit.
- `<slug>` is a meaningful kebab-case identifier — `home`, `maestro`,
  `actions`, `simplify`. Unique by intent, not by counter, so two
  parallel branches never contend for the same id.
- `<type>` ∈ `{feat, fix, chore, docs}` (conventional commits).

Enforced by `scripts/feature-list-check.js` and step 6 of
`scripts/harness-ci-checks.sh`. The payoff: `git log --all
--grep='(ui-home)'` returns the full story for that feature across
every branch and commit.

## Features as files

Features live in `features/`, one JSON file per feature, named after
the id (`features/ui-home.json` carries `"id": "ui-home"`). The
validator enforces the filename↔id match.

Two parallel branches that add different features touch different
files — no merge conflict. A branch that flips a feature to `done`
only edits that feature's file; concurrent branches editing other
features don't collide. This was the original problem with the
single-file `feature_list.json` array.

The trade-off: WIP=1 is enforced *per branch* by the validator (one
in_progress at a time on the branch's view), but if two branches each
mark a different feature `in_progress` and both merge to main, main
will transiently see WIP=2. The merging human resolves by demoting one
to `todo` or marking it `done`. Acceptable.

## Definition of done

A change is `done` only when every one of these holds:

- Verification list in `features/<id>.json` has been performed.
- `npm run verify` is green.
- App starts via `npm run start` on at least one platform (or, for
  non-UI features, the workflow / script the feature adds runs cleanly).
- `features/<id>.json` updated **in the PR's own diff before merge**:
  `"status": "done"`, `"passes": true`, `"commitSha"` set to the
  latest implementation commit on the branch.
- Any non-obvious decisions appended to `DECISIONS.md`.
