# docs/HARNESS.md — Working contract

Grounded in [Learn Harness Engineering](https://walkinglabs.github.io/learn-harness-engineering).
The lecture source is the canonical reference; this doc is the project's
short adaptation.

## Five subsystems (Lecture 02)

| Subsystem | Lives in |
| --- | --- |
| Instructions | `AGENTS.md`, `CLAUDE.md`, `docs/*.md` |
| State | `feature_list.json`, `PROGRESS.md`, `DECISIONS.md`, `git log` |
| Verification | `npm run verify`, `init.sh`, per-feature verification lists |
| Scope | `feature_list.json` with `wipLimit: 1` |
| Session lifecycle | `init.sh` (start), `docs/SESSION.md` (end) |

## Working rules

1. **WIP = 1.** One in-flight feature per branch. Drive-by debt becomes
   a new feature in `feature_list.json`, not a side-edit. (Lecture 07)
2. **Repo is the system of record.** If a fact isn't in a file, it
   doesn't exist. (Lecture 03)
3. **Verification is what makes "done" real.** A feature is `done`
   only when its `verification[]` items have been performed and
   `npm run verify` is green. Code inspection doesn't count.
   (Lecture 09)
4. **Initialize before every session.** Run `./init.sh`. If the
   baseline is red, fix the foundation before touching new code.
   (Lecture 06)
5. **Leave a clean state.** PR opened, `PROGRESS.md` reflects reality,
   verify green. (Lecture 12)

## Naming standard

The feature ID is the load-bearing identifier across all three forms
of state.

| Artefact | Format | Example |
| --- | --- | --- |
| Feature ID (`feature_list.json[].id`) | `<category>-<NNN>` | `ui-001`, `e2e-001` |
| Branch name | `<type>/<feature-id>-<slug>` | `feat/ui-001-home` |
| Commit subject | `<type>(<feature-id>): <subject>` | `feat(e2e-001): …` |

- `<NNN>` is zero-padded to 3 digits.
- `<type>` ∈ `{feat, fix, chore, docs}`.
- `<slug>` is 1–3 kebab words describing the artefact or action.

Enforced by `scripts/feature-list-check.js`. The payoff is that
`git log --all --grep='(ui-002)'` returns the full story for a feature.

## Definition of done

A change is `done` only when every one of these holds:

- Verification list in `feature_list.json` has been performed.
- `npm run verify` is green.
- App starts via `npm run start` on at least one platform (or, for
  non-UI features, the workflow / script the feature adds runs cleanly).
- `feature_list.json[].status` = `"done"`, `passes: true`,
  `commitSha` filled in.
- `PROGRESS.md` updated; any non-obvious decisions appended to
  `DECISIONS.md`.
