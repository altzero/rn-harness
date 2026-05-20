#!/usr/bin/env bash
# scripts/run-maestro.sh — harness wrapper around `maestro test`.
#
# Usage:
#   bash scripts/run-maestro.sh <path-to-flow.yaml> [extra maestro args]
#
# Behavior:
#   - Verifies `maestro` is installed; prints install hint if not.
#   - Verifies at least one iOS sim OR Android emulator is booted.
#   - Runs the flow, capturing stdout/stderr to tmp/diagnostics/<ts>-<flow>.log.
#   - Copies any takeScreenshot artifacts (default Maestro location) into
#     tmp/diagnostics/ keyed by timestamp.
#   - Emits [ok]/[fail] lines so an agent can grep the failure step.

set -uo pipefail

# Default appId for flows that reference ${APP_ID}. Expo Go's bundle id
# unless the caller exported a different one (CI does this from the
# built .app's CFBundleIdentifier).
export APP_ID="${APP_ID:-host.exp.exponent}"

bold()  { printf '\033[1m%s\033[0m\n' "$*"; }
ok()    { printf '  \033[32m[ok]\033[0m %s\n' "$*"; }
warn()  { printf '  \033[33m[warn]\033[0m %s\n' "$*"; }
fail()  { printf '  \033[31m[fail]\033[0m %s\n' "$*" >&2; exit 1; }

FLOW="${1:-}"
if [ -z "$FLOW" ]; then
  fail "missing argument. Usage: bash scripts/run-maestro.sh <path-to-flow.yaml>"
fi
if [ ! -f "$FLOW" ]; then
  fail "flow file not found: $FLOW"
fi
shift || true

bold "[maestro 1/4] check maestro is installed"
if ! command -v maestro >/dev/null; then
  fail "maestro is not installed. Install with: curl -Ls 'https://get.maestro.mobile.dev' | bash"
fi
ok "maestro $(maestro --version 2>/dev/null | head -n 1)"

bold "[maestro 2/4] check a device is available"
HAS_IOS=0
HAS_ANDROID=0
if command -v xcrun >/dev/null; then
  if xcrun simctl list devices booted 2>/dev/null | grep -qE '\(Booted\)'; then
    HAS_IOS=1
    ok "iOS simulator booted: $(xcrun simctl list devices booted | grep -E '\(Booted\)' | head -n 1 | sed 's/^[[:space:]]*//')"
  fi
fi
if command -v adb >/dev/null; then
  if adb devices 2>/dev/null | tail -n +2 | grep -q "device$"; then
    HAS_ANDROID=1
    ok "Android device/emulator detected: $(adb devices | tail -n +2 | grep 'device$' | head -n 1)"
  fi
fi
if [ "$HAS_IOS" -eq 0 ] && [ "$HAS_ANDROID" -eq 0 ]; then
  echo
  warn "no booted iOS simulator or Android emulator detected"
  echo "  Boot one before retrying:"
  echo "    - iOS:     npm run sim:ios"
  echo "    - Android: npm run sim:android"
  fail "aborting — no device to run against"
fi

TS=$(date +%Y%m%dT%H%M%S)
FLOW_BASE="$(basename "$FLOW" .yaml)"
ART_DIR="tmp/diagnostics"
mkdir -p "$ART_DIR"
LOG_FILE="$ART_DIR/${TS}-maestro-${FLOW_BASE}.log"

bold "[maestro 3/4] run flow: $FLOW"
echo "  log: $LOG_FILE"
echo "  APP_ID=$APP_ID"
# Use --format junit + --output for machine-readable result alongside the log.
# Pass APP_ID via -e so it is visible to Maestro's JS engine; exporting
# from the shell alone does not populate the engine's globals.
JUNIT_FILE="$ART_DIR/${TS}-maestro-${FLOW_BASE}.junit.xml"
set +e
maestro test "$FLOW" \
  -e APP_ID="$APP_ID" \
  --format junit \
  --output "$JUNIT_FILE" \
  "$@" 2>&1 | tee "$LOG_FILE"
RC=${PIPESTATUS[0]}
set -e

bold "[maestro 4/4] collect artifacts"
# Maestro drops screenshots in ~/.maestro/tests/<id>/ by default; copy any
# .png files newer than the start of this run into our diagnostics dir so
# the agent can find them in one place.
MAESTRO_HOME="${MAESTRO_HOME:-$HOME/.maestro}"
if [ -d "$MAESTRO_HOME/tests" ]; then
  COUNT=0
  while IFS= read -r f; do
    cp "$f" "$ART_DIR/${TS}-maestro-${FLOW_BASE}-$(basename "$f")"
    COUNT=$((COUNT+1))
  done < <(find "$MAESTRO_HOME/tests" -type f -name "*.png" -newer "$LOG_FILE" 2>/dev/null)
  if [ "$COUNT" -gt 0 ]; then
    ok "copied $COUNT screenshot(s) to $ART_DIR/"
  fi
fi

echo
if [ "$RC" -eq 0 ]; then
  bold "maestro flow passed: $FLOW"
  echo "  artifacts: $ART_DIR/${TS}-maestro-${FLOW_BASE}.*"
  exit 0
else
  bold "maestro flow FAILED: $FLOW (exit $RC)"
  echo "  see: $LOG_FILE"
  echo "  see: $JUNIT_FILE"
  exit "$RC"
fi
