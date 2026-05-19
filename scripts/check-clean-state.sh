#!/usr/bin/env bash
# check-clean-state.sh — Lecture 12: leave a clean state. Run before ending
# a session. Exits non-zero if anything looks off.
set -uo pipefail

bold()  { printf '\033[1m%s\033[0m\n' "$*"; }
ok()    { printf '  \033[32m[ok]\033[0m %s\n' "$*"; }
warn()  { printf '  \033[33m[warn]\033[0m %s\n' "$*"; }
problems=0

bold "[clean 1/5] working tree status"
if [ -d .git ] && ! git diff --quiet HEAD 2>/dev/null; then
  warn "uncommitted changes — make sure each is explained in claude-progress.md:"
  git status --short | sed 's/^/    /'
  problems=$((problems+1))
else
  ok "working tree clean (or not yet a git repo)"
fi

bold "[clean 2/5] verify is green"
if npm run -s verify >/tmp/verify.log 2>&1; then
  ok "npm run verify passes"
else
  warn "npm run verify is red — last 20 lines:"
  tail -n 20 /tmp/verify.log | sed 's/^/    /'
  problems=$((problems+1))
fi

bold "[clean 3/5] stray debug markers"
patterns='(\.only\(|\.skip\(|xit\(|fdescribe\(|fit\(|^[[:space:]]*debugger;)'
hits=$(grep -RInE "$patterns" --include='*.ts' --include='*.tsx' app components lib hooks __tests__ 2>/dev/null || true)
if [ -n "$hits" ]; then
  warn "found focused/skipped tests or debugger statements:"
  echo "$hits" | sed 's/^/    /'
  problems=$((problems+1))
else
  ok "no stray debug markers"
fi

bold "[clean 4/5] feature_list.json + claude-progress.md consistency"
node scripts/feature-list-check.js >/dev/null 2>&1 || { warn "feature_list.json invalid"; problems=$((problems+1)); }
if [ -f claude-progress.md ]; then
  if ! grep -q "Next action" claude-progress.md; then
    warn "claude-progress.md is missing a 'Next action' block"
    problems=$((problems+1))
  else
    ok "claude-progress.md has a Next action block"
  fi
else
  warn "claude-progress.md missing"
  problems=$((problems+1))
fi

bold "[clean 5/5] tmp/ diagnostics"
if [ -d tmp ] && [ -n "$(ls -A tmp 2>/dev/null)" ]; then
  warn "tmp/ is non-empty — ensure each file is referenced from claude-progress.md:"
  ls tmp | sed 's/^/    /'
fi
ok "tmp scan complete"

echo
if [ "$problems" -eq 0 ]; then
  bold "clean state — ok to end session"
  exit 0
else
  bold "clean state — $problems issue(s); fix or document before ending session"
  exit 1
fi
