#!/usr/bin/env bash
# scripts/sim-android.sh — boot an Android emulator, optionally screenshot.
#
# Usage:
#   bash scripts/sim-android.sh                # boot default AVD if none running
#   bash scripts/sim-android.sh screenshot     # boot + screenshot
#   AVD=Pixel_8_API_34 bash scripts/sim-android.sh

set -uo pipefail

bold()  { printf '\033[1m%s\033[0m\n' "$*"; }
ok()    { printf '  \033[32m[ok]\033[0m %s\n' "$*"; }
fail()  { printf '  \033[31m[fail]\033[0m %s\n' "$*" >&2; exit 1; }

if ! command -v adb >/dev/null; then
  fail "adb not found. Install Android Studio + platform-tools, then add platform-tools to PATH."
fi

ACTION="${1:-boot}"

bold "[sim:android 1/2] ensure an emulator is running"
if adb devices | tail -n +2 | grep -q "device$"; then
  ok "device already attached: $(adb devices | tail -n +2 | grep 'device$' | head -n 1)"
else
  if ! command -v emulator >/dev/null; then
    fail "emulator binary not on PATH. Add \$ANDROID_HOME/emulator to PATH."
  fi
  AVDS=$(emulator -list-avds 2>/dev/null || true)
  if [ -z "$AVDS" ]; then
    fail "no AVDs installed. Create one in Android Studio → Device Manager."
  fi
  AVD="${AVD:-$(echo "$AVDS" | head -n 1)}"
  echo "  booting AVD '$AVD'…"
  ( emulator -avd "$AVD" -no-snapshot-save >/dev/null 2>&1 & )
  echo "  waiting for device…"
  adb wait-for-device
  for _ in $(seq 1 60); do
    BOOT=$(adb shell getprop sys.boot_completed 2>/dev/null | tr -d '\r')
    if [ "$BOOT" = "1" ]; then break; fi
    sleep 1
  done
  ok "AVD '$AVD' booted"
fi

case "$ACTION" in
  boot)
    bold "[sim:android 2/2] done — emulator is ready"
    ;;
  screenshot)
    bold "[sim:android 2/2] capture screenshot"
    mkdir -p tmp/diagnostics
    TS=$(date +%Y%m%dT%H%M%S)
    OUT="tmp/diagnostics/${TS}-sim-android.png"
    adb exec-out screencap -p > "$OUT"
    ok "wrote $OUT"
    ;;
  *)
    fail "unknown action '$ACTION'. Use: boot | screenshot"
    ;;
esac
