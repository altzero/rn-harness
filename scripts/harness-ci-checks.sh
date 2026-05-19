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

bold "[harness-ci 1/5] claude-progress.md has a Next action block"
if [ ! -f claude-progress.md ]; then
  fail "claude-progress.md is missing"
fi
if ! grep -q "Next action" claude-progress.md; then
  fail "claude-progress.md is missing a 'Next action' section — see docs/SESSION.md"
fi
ok "Next action block present"

bold "[harness-ci 2/5] no stray .only / .skip / xit / debugger in committed code"
PATTERNS='(\.only\(|\.skip\(|xit\(|fdescribe\(|fit\(|^[[:space:]]*debugger;)'
DIRS=()
for d in app components lib hooks __tests__; do
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

bold "[harness-ci 3/5] every 'done' feature has a non-empty commitSha"
MISSING=$(node -e '
  const f = JSON.parse(require("fs").readFileSync("feature_list.json","utf8"));
  const bad = f.features.filter(x => x.status === "done" && (!x.commitSha || x.commitSha.length < 7));
  if (bad.length) { console.log(bad.map(x => x.id).join(",")); process.exit(1); }
') || true
if [ -n "$MISSING" ]; then
  fail "done features missing commitSha: $MISSING"
fi
ok "every done feature has commitSha"

bold "[harness-ci 4/5] no AGENTS.md / CLAUDE.md / required docs deleted"
REQUIRED=(AGENTS.md CLAUDE.md init.sh feature_list.json claude-progress.md docs/HARNESS.md docs/ARCHITECTURE.md docs/RN_PLATFORM.md docs/VERIFICATION.md docs/E2E_TESTING.md)
for f in "${REQUIRED[@]}"; do
  if [ ! -f "$f" ]; then
    fail "required harness file missing: $f"
  fi
done
ok "all required harness files present"

bold "[harness-ci 5/5] no committed .env or signing material"
LEAKS=$(git ls-files | grep -E '(\.env$|\.env\.|\.p12$|\.jks$|\.mobileprovision$|\.key$)' || true)
if [ -n "$LEAKS" ]; then
  echo "$LEAKS" | sed 's/^/    /'
  fail "secrets-shaped files appear in the repo — add to .gitignore and rotate"
fi
ok "no secret-shaped files committed"

echo
bold "harness CI invariants ok"
