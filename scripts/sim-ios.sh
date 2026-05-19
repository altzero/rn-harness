#!/usr/bin/env bash
# scripts/sim-ios.sh — boot an iOS simulator, optionally take a screenshot.
#
# Usage:
#   bash scripts/sim-ios.sh                # boot the default sim if needed
#   bash scripts/sim-ios.sh screenshot     # boot + screenshot to tmp/diagnostics/
#   DEVICE="iPhone 16 Pro" bash scripts/sim-ios.sh
#
# Why this exists: this is the "boot the foundation" half of the agent's
# verification loop. It is deliberately separate from `npm run ios` (which
# also builds and installs the app). The agent should be able to:
#   1. boot a sim cheaply
#   2. install/launch the app (npm run ios)
#   3. assert state via Maestro or screenshot

set -uo pipefail

bold()  { printf '\033[1m%s\033[0m\n' "$*"; }
ok()    { printf '  \033[32m[ok]\033[0m %s\n' "$*"; }
fail()  { printf '  \033[31m[fail]\033[0m %s\n' "$*" >&2; exit 1; }

if ! command -v xcrun >/dev/null; then
  fail "xcrun not found. Install Xcode (App Store) and the command line tools (xcode-select --install)."
fi

DEVICE="${DEVICE:-iPhone 16 Pro}"
ACTION="${1:-boot}"

bold "[sim:ios 1/2] ensure a simulator is booted"
BOOTED=$(xcrun simctl list devices booted | grep -E '\(Booted\)' | head -n 1 || true)
if [ -n "$BOOTED" ]; then
  ok "already booted: $(echo "$BOOTED" | sed 's/^[[:space:]]*//')"
else
  echo "  booting '$DEVICE'…"
  if ! xcrun simctl boot "$DEVICE" 2>/dev/null; then
    echo "  device '$DEVICE' not found. Available iOS sims:"
    xcrun simctl list devices available | grep -E '^[[:space:]]+iPhone|^[[:space:]]+iPad' | sed 's/^/    /'
    fail "set DEVICE=... and retry"
  fi
  open -a Simulator
  # Wait until the device reports as booted.
  for _ in $(seq 1 30); do
    if xcrun simctl list devices booted | grep -qE '\(Booted\)'; then break; fi
    sleep 0.5
  done
  ok "booted '$DEVICE'"
fi

case "$ACTION" in
  boot)
    bold "[sim:ios 2/2] done — simulator is ready"
    ;;
  screenshot)
    bold "[sim:ios 2/2] capture screenshot"
    mkdir -p tmp/diagnostics
    TS=$(date +%Y%m%dT%H%M%S)
    OUT="tmp/diagnostics/${TS}-sim-ios.png"
    xcrun simctl io booted screenshot "$OUT"
    ok "wrote $OUT"
    ;;
  *)
    fail "unknown action '$ACTION'. Use: boot | screenshot"
    ;;
esac
