#!/usr/bin/env bash
# scripts/harness-ci-checks.sh — invariants that should hold on every CI
# build but are NOT covered by tsc / lint / jest.
#
# Unlike scripts/check-clean-state.sh, this script makes no assumptions
# about the working tree (CI checkouts are always clean) and never
# inspects `npm run verify` (CI runs that separately).
#
# Exits non-zero on the first violation with a clear remediation line.

set -uo pipefail

bold()  { printf '\033[1m%s\033[0m\n' "$*"; }
ok()    { printf '  \033[32m[ok]\033[0m %s\n' "$*"; }
fail()  { printf '  \033[31m[fail]\033[0m %s\n' "$*" >&2; exit 1; }

problems=0

bold "[harness-ci 1/5] no stray .only / .skip / xit / debugger in committed code"
PATTERNS='(\.only\(|\.skip\(|xit\(|fdescribe\(|fit\(|^[[:space:]]*debugger;)'
DIRS=()
for d in app components hooks; do
  [ -d "$d" ] && DIRS+=("$d")
done
if [ "${#DIRS[@]}" -gt 0 ]; then
  if HITS=$(grep -RInE "$PATTERNS" --include='*.ts' --include='*.tsx' "${DIRS[@]}" 2>/dev/null); then
    if [ -n "$HITS" ]; then
      echo "$HITS" | sed 's/^/    /'
      fail "stray focused/skipped tests or debugger statements found"
    fi
  fi
fi
ok "no stray debug markers"

bold "[harness-ci 2/5] every 'done' feature has a non-empty commitSha"
MISSING=$(node -e '
  const fs = require("fs"); const path = require("path");
  const dir = path.resolve("features");
  const bad = fs.readdirSync(dir).filter(f => f.endsWith(".json")).map(f => {
    const x = JSON.parse(fs.readFileSync(path.join(dir, f), "utf8"));
    return (x.status === "done" && (!x.commitSha || x.commitSha.length < 7)) ? x.id : null;
  }).filter(Boolean);
  if (bad.length) { console.log(bad.join(",")); process.exit(1); }
') || true
if [ -n "$MISSING" ]; then
  fail "done features missing commitSha: $MISSING"
fi
ok "every done feature has commitSha"

bold "[harness-ci 3/5] required harness files present"
REQUIRED=(AGENTS.md CLAUDE.md init.sh DECISIONS.md docs/HARNESS.md docs/SESSION.md docs/ARCHITECTURE.md docs/RN_PLATFORM.md features)
for f in "${REQUIRED[@]}"; do
  if [ ! -e "$f" ]; then
    fail "required harness path missing: $f"
  fi
done
ok "all required harness paths present"

bold "[harness-ci 4/5] no committed .env or signing material"
LEAKS=$(git ls-files | grep -E '(\.env$|\.env\.|\.p12$|\.jks$|\.mobileprovision$|\.key$)' || true)
if [ -n "$LEAKS" ]; then
  echo "$LEAKS" | sed 's/^/    /'
  fail "secrets-shaped files appear in the repo — add to .gitignore and rotate"
fi
ok "no secret-shaped files committed"

bold "[harness-ci 5/5] branch name follows naming standard"
# In CI prefer GITHUB_HEAD_REF (PR source branch) or GITHUB_REF_NAME.
# Locally, fall back to `git branch --show-current`.
BRANCH="${GITHUB_HEAD_REF:-${GITHUB_REF_NAME:-$(git branch --show-current 2>/dev/null || echo '')}}"
# New shape: <type>/<feature-id> where feature-id = <category>-<slug>
# (at least one dash). No -NNN suffix. Optional trailing -<extra-slug>
# segments are allowed for when a feature has multiple branches.
BRANCH_RE='^(feat|fix|chore|docs)/[a-z][a-z0-9]*(-[a-z][a-z0-9]*)+(-[a-z][a-z0-9]*)*$'
if [ -z "$BRANCH" ]; then
  ok "branch name not detectable (detached HEAD or no git) — skipped"
elif echo "$BRANCH" | grep -qE '^(main|master|develop)$'; then
  ok "branch '$BRANCH' is a long-lived trunk — skipped"
elif echo "$BRANCH" | grep -qE '^(release|hotfix)/'; then
  ok "branch '$BRANCH' is a release/hotfix branch — skipped"
elif ! echo "$BRANCH" | grep -qE "$BRANCH_RE"; then
  fail "branch '$BRANCH' does not match <type>/<feature-id> (see docs/HARNESS.md → Naming standard). type ∈ {feat,fix,chore,docs}; feature-id e.g. 'ui-home', 'ci-actions'."
else
  # Strip leading type/, walk the remainder; the longest filename in
  # features/ that prefix-matches is the feature id this branch claims.
  REST=$(echo "$BRANCH" | sed -E 's|^[a-z]+/||')
  FID=""
  while [ -n "$REST" ]; do
    if [ -f "features/${REST}.json" ]; then
      FID="$REST"
      break
    fi
    NEXT=$(echo "$REST" | sed -E 's|-[^-]+$||')
    [ "$NEXT" = "$REST" ] && break
    REST="$NEXT"
  done
  if [ -z "$FID" ]; then
    fail "branch '$BRANCH' does not reference any feature id in features/"
  fi
  ok "branch '$BRANCH' follows naming standard; feature '$FID' exists"
fi

echo
bold "harness CI invariants ok"
