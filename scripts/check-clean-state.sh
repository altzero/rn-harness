#!/usr/bin/env bash
# check-clean-state.sh — Lecture 12: leave a clean state. Run before
# ending a session. Exits non-zero if anything looks off.

set -uo pipefail

bold()  { printf '\033[1m%s\033[0m\n' "$*"; }
ok()    { printf '  \033[32m[ok]\033[0m %s\n' "$*"; }
warn()  { printf '  \033[33m[warn]\033[0m %s\n' "$*"; }
problems=0

bold "[clean 1/4] working tree status"
if [ -d .git ] && ! git diff --quiet HEAD 2>/dev/null; then
  warn "uncommitted changes — commit or document each:"
  git status --short | sed 's/^/    /'
  problems=$((problems+1))
else
  ok "working tree clean"
fi

bold "[clean 2/4] verify is green"
if npm run -s verify >/tmp/verify.log 2>&1; then
  ok "npm run verify passes"
else
  warn "npm run verify is red — last 20 lines:"
  tail -n 20 /tmp/verify.log | sed 's/^/    /'
  problems=$((problems+1))
fi

bold "[clean 3/4] stray debug markers"
patterns='(\.only\(|\.skip\(|xit\(|fdescribe\(|fit\(|^[[:space:]]*debugger;)'
DIRS=()
for d in app components hooks; do [ -d "$d" ] && DIRS+=("$d"); done
if [ "${#DIRS[@]}" -gt 0 ]; then
  hits=$(grep -RInE "$patterns" --include='*.ts' --include='*.tsx' "${DIRS[@]}" 2>/dev/null || true)
  if [ -n "$hits" ]; then
    warn "stray focused/skipped tests or debugger:"
    echo "$hits" | sed 's/^/    /'
    problems=$((problems+1))
  else
    ok "no stray debug markers"
  fi
else
  ok "no source dirs to scan"
fi

bold "[clean 4/4] in-flight feature is flipped to done if branch is ready"
# Only enforce on feature branches (matches the naming standard).
BRANCH=$(git branch --show-current 2>/dev/null || echo '')
if echo "$BRANCH" | grep -qE '^(feat|fix|chore|docs)/'; then
  # Walk the branch slug back through segments to find the feature id.
  REST=$(echo "$BRANCH" | sed -E 's|^[a-z]+/||')
  FID=""
  while [ -n "$REST" ]; do
    if [ -f "features/${REST}.json" ]; then FID="$REST"; break; fi
    NEXT=$(echo "$REST" | sed -E 's|-[^-]+$||')
    [ "$NEXT" = "$REST" ] && break
    REST="$NEXT"
  done
  if [ -z "$FID" ]; then
    ok "branch '$BRANCH' has no feature id — skipped"
  else
    STATUS=$(node -e "console.log(require('./features/${FID}.json').status)" 2>/dev/null || echo "")
    if [ "$STATUS" = "in_progress" ]; then
      warn "feature '$FID' is still in_progress — flip to done before merging (see docs/SESSION.md)"
      # Soft warning, not a hard failure: the work may legitimately not be
      # ready to merge yet.
    elif [ "$STATUS" = "done" ]; then
      ok "feature '$FID' is done — ready to merge"
    else
      ok "feature '$FID' is $STATUS"
    fi
  fi
else
  ok "not on a feature branch — skipped"
fi

echo
if [ "$problems" -eq 0 ]; then
  bold "clean state — ok to end session"
  exit 0
else
  bold "clean state — $problems issue(s); fix or document before ending session"
  exit 1
fi
