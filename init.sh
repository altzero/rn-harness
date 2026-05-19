#!/usr/bin/env bash
# init.sh — harness initialization phase.
#
# This script is the FOUNDATION step (per harness engineering, lecture 06).
# It is not the same as building the walls (running the app, writing code).
# Its job is to make the environment ready and to FAIL LOUDLY if anything is
# wrong. An agent or a human should be able to read its output and know the
# exact next action.
#
# Acceptance: every check below either passes with a [ok] line or aborts the
# script with a non-zero exit and a clear remediation hint.

set -euo pipefail

bold()  { printf '\033[1m%s\033[0m\n' "$*"; }
ok()    { printf '  \033[32m[ok]\033[0m %s\n' "$*"; }
warn()  { printf '  \033[33m[warn]\033[0m %s\n' "$*"; }
fail()  { printf '  \033[31m[fail]\033[0m %s\n' "$*" >&2; exit 1; }

bold "[init 1/7] confirm repository root"
if [ ! -f "package.json" ] || [ ! -f "AGENTS.md" ]; then
  fail "run init.sh from the repo root. Try: cd \$(git rev-parse --show-toplevel) && ./init.sh"
fi
ok "in repo root: $(pwd)"

bold "[init 2/7] node + package manager"
if ! command -v node >/dev/null; then fail "node missing — install Node 20+ (nvm install 20)"; fi
NODE_MAJOR=$(node -p 'process.versions.node.split(".")[0]')
if [ "$NODE_MAJOR" -lt 20 ]; then
  fail "node $NODE_MAJOR.x detected; Expo SDK 54 requires Node >= 20. Run: nvm use 20"
fi
ok "node $(node -v)"
if ! command -v npm >/dev/null; then fail "npm missing"; fi
ok "npm $(npm -v)"

bold "[init 3/7] install dependencies (idempotent)"
if [ ! -d node_modules ] || [ package.json -nt node_modules ]; then
  npm install --no-audit --no-fund
  ok "dependencies installed"
else
  ok "node_modules up to date (package.json older than node_modules)"
fi

bold "[init 4/7] typescript health"
npx --no-install tsc --noEmit || fail "typecheck failed — fix before continuing"
ok "tsc --noEmit clean"

bold "[init 5/7] lint health"
npm run -s lint || fail "lint failed — fix before continuing"
ok "lint clean"

bold "[init 6/7] feature_list.json sanity"
node scripts/feature-list-check.js || fail "feature_list.json is invalid"
ok "feature_list.json parses and is well-formed"

bold "[init 7/7] previous session handoff"
if [ -f claude-progress.md ]; then
  echo
  echo "  Last 30 lines of claude-progress.md (read this before acting):"
  echo "  ----------------------------------------------------------------"
  tail -n 30 claude-progress.md | sed 's/^/  | /'
  echo "  ----------------------------------------------------------------"
fi

echo
bold "init complete — environment is healthy"
echo "Next: run 'npm run verify' to confirm baseline, then pick the next feature"
echo "      from feature_list.json (status: in_progress, then todo)."
