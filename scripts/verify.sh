#!/usr/bin/env bash
# verify.sh — baseline gate. See docs/VERIFICATION.md.
set -euo pipefail

bold()  { printf '\033[1m%s\033[0m\n' "$*"; }
ok()    { printf '  \033[32m[ok]\033[0m %s\n' "$*"; }
fail()  { printf '  \033[31m[fail]\033[0m %s\n' "$*" >&2; exit 1; }

if [ -f .harness-waiver ]; then
  echo "[verify] WARNING: .harness-waiver is present. Reasons:"
  sed 's/^/  | /' .harness-waiver
  echo
fi

bold "[verify 1/4] typecheck"
npx --no-install tsc --noEmit || fail "tsc --noEmit failed"
ok "tsc clean"

bold "[verify 2/4] lint"
npm run -s lint || fail "lint failed"
ok "lint clean"

bold "[verify 3/4] tests"
npm test -- --silent || fail "tests failed"
ok "tests pass"

bold "[verify 4/4] feature_list.json"
node scripts/feature-list-check.js || fail "feature_list.json invalid"
ok "feature_list.json valid"

echo
bold "verify complete — baseline is green"
