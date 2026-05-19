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

bold "[harness-ci 1/6] PROGRESS.md has a Next steps block"
if [ ! -f PROGRESS.md ]; then
  fail "PROGRESS.md is missing"
fi
if ! grep -q "^## Next steps" PROGRESS.md; then
  fail "PROGRESS.md is missing a '## Next steps' section — see docs/SESSION.md"
fi
ok "Next steps block present"

bold "[harness-ci 2/6] no stray .only / .skip / xit / debugger in committed code"
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

bold "[harness-ci 3/6] every 'done' feature has a non-empty commitSha"
MISSING=$(node -e '
  const f = JSON.parse(require("fs").readFileSync("feature_list.json","utf8"));
  const bad = f.features.filter(x => x.status === "done" && (!x.commitSha || x.commitSha.length < 7));
  if (bad.length) { console.log(bad.map(x => x.id).join(",")); process.exit(1); }
') || true
if [ -n "$MISSING" ]; then
  fail "done features missing commitSha: $MISSING"
fi
ok "every done feature has commitSha"

bold "[harness-ci 4/6] no AGENTS.md / CLAUDE.md / required docs deleted"
REQUIRED=(AGENTS.md CLAUDE.md init.sh feature_list.json PROGRESS.md DECISIONS.md docs/HARNESS.md docs/SESSION.md docs/ARCHITECTURE.md docs/RN_PLATFORM.md)
for f in "${REQUIRED[@]}"; do
  if [ ! -f "$f" ]; then
    fail "required harness file missing: $f"
  fi
done
ok "all required harness files present"

bold "[harness-ci 5/6] no committed .env or signing material"
LEAKS=$(git ls-files | grep -E '(\.env$|\.env\.|\.p12$|\.jks$|\.mobileprovision$|\.key$)' || true)
if [ -n "$LEAKS" ]; then
  echo "$LEAKS" | sed 's/^/    /'
  fail "secrets-shaped files appear in the repo — add to .gitignore and rotate"
fi
ok "no secret-shaped files committed"

bold "[harness-ci 6/6] branch name follows naming standard"
# In CI prefer GITHUB_HEAD_REF (PR source branch) or GITHUB_REF_NAME.
# Locally, fall back to `git branch --show-current`.
BRANCH="${GITHUB_HEAD_REF:-${GITHUB_REF_NAME:-$(git branch --show-current 2>/dev/null || echo '')}}"
if [ -z "$BRANCH" ]; then
  ok "branch name not detectable (detached HEAD or no git) — skipped"
elif echo "$BRANCH" | grep -qE '^(main|master|develop)$'; then
  ok "branch '$BRANCH' is a long-lived trunk — skipped"
elif echo "$BRANCH" | grep -qE '^(release|hotfix)/'; then
  ok "branch '$BRANCH' is a release/hotfix branch — skipped"
elif ! echo "$BRANCH" | grep -qE '^(feat|fix|chore|docs)/[a-z][a-z0-9]*(-[a-z][a-z0-9]*)*-[0-9]{3}-[a-z][a-z0-9-]*$'; then
  fail "branch '$BRANCH' does not match <type>/<feature-id>-<slug> (see docs/HARNESS.md → Naming standards). type ∈ {feat,fix,chore,docs}; feature-id e.g. 'ui-001'; slug 1-3 kebab words."
else
  # Verify the embedded feature id exists in feature_list.json.
  FID=$(echo "$BRANCH" | sed -E 's|^[a-z]+/([a-z][a-z0-9]*(-[a-z][a-z0-9]*)*-[0-9]{3})-.*$|\1|')
  if ! node -e '
    const f = JSON.parse(require("fs").readFileSync("feature_list.json","utf8"));
    if (!f.features.some(x => x.id === process.argv[1])) process.exit(1);
  ' "$FID"; then
    fail "branch '$BRANCH' references feature id '$FID' which is not in feature_list.json"
  fi
  ok "branch '$BRANCH' follows naming standard; feature '$FID' exists"
fi

echo
bold "harness CI invariants ok"
