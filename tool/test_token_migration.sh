#!/usr/bin/env bash
#
# Upgrade test: tokens written by logto_dart_sdk 3.x must still be readable after
# upgrading to 4.0.
#
# 3.x stored tokens through flutter_secure_storage 9.x with the Jetpack
# `EncryptedSharedPreferences` backend. 4.0 uses 10.x, which reads that data once and
# rewrites it in the new AES-GCM format (`migrateOnAlgorithmChange`, on by default).
# That bridge exists only in 10.x -- 11.x deleted it -- so this test is what stops the
# flutter_secure_storage constraint being raised past 10.x without a deliberate
# two-step migration.
#
# Why it is shaped like this rather than as an integration_test:
#   * A single build resolves one flutter_secure_storage version, and 10.x *ignores*
#     `encryptedSharedPreferences`, so v9-format data cannot be produced from a 10.x
#     build. The two phases therefore need two builds.
#   * `flutter test integration_test/...` uninstalls the app when it finishes, which
#     erases the app data the second phase has to read. So each phase is built as a
#     standalone app entrypoint and installed with `adb install -r`, which replaces the
#     APK while preserving the data directory.
#
# Verified negative control: rerunning phase B with flutter_secure_storage 11.0.0
# (and compileSdk 37, which 11.x requires) makes it fail with "got null" -- 11.x deleted
# the bridge, so this test does detect the regression it exists to catch. To reproduce,
# swap the phase B override below to 11.0.0.
#
# Usage: tool/test_token_migration.sh [device-id]
set -euo pipefail

cd "$(dirname "$0")/.."
readonly EXAMPLE="$PWD/example"
readonly PUBSPEC="$EXAMPLE/pubspec.yaml"
readonly PUBSPEC_LOCK="$EXAMPLE/pubspec.lock"
readonly APK="$EXAMPLE/build/app/outputs/flutter-apk/app-debug.apk"
readonly PACKAGE="com.example.example"
readonly MARKER="LOGTO_MIGRATION_RESULT"
BACKUP="$(mktemp)"
LOCK_BACKUP="$(mktemp)"

DEVICE="${1:-}"
if [[ -z "$DEVICE" ]]; then
  DEVICE="$(adb devices | awk '/\tdevice$/ {print $1; exit}')"
fi
if [[ -z "$DEVICE" ]]; then
  echo "error: no attached Android device; boot an emulator or pass a device id" >&2
  exit 1
fi
export ANDROID_SERIAL="$DEVICE"
echo "==> device: $DEVICE"

# pubspec.lock is tracked, and both phases rewrite it via `flutter pub get`. Restoring it
# from a snapshot rather than regenerating it keeps the working tree clean even when
# resolution would now pick different versions (a newer 10.x, a different Dart SDK).
cp "$PUBSPEC" "$BACKUP"
cp "$PUBSPEC_LOCK" "$LOCK_BACKUP"
cleanup() {
  cp "$BACKUP" "$PUBSPEC"
  cp "$LOCK_BACKUP" "$PUBSPEC_LOCK"
  rm -f "$BACKUP" "$LOCK_BACKUP"
  # Re-resolve so .dart_tool matches the restored files again. pub honours an existing
  # lockfile whose versions still satisfy the constraints, so this leaves it untouched.
  (cd "$EXAMPLE" && flutter pub get >/dev/null 2>&1) || true
}
trap cleanup EXIT

# Runs one phase: build the entrypoint, reinstall over any existing data, launch, and
# wait for the marker the entrypoint writes to logcat.
run_phase() {
  local label="$1" entrypoint="$2" keep_data="$3"

  echo "==> $label: building"
  (cd "$EXAMPLE" && flutter build apk --debug -t "$entrypoint" >/dev/null)

  if [[ "$keep_data" == "fresh" ]]; then
    adb uninstall "$PACKAGE" >/dev/null 2>&1 || true
  fi

  echo "==> $label: installing"
  # -r replaces the APK in place; without it the data written by the previous phase
  # would be gone and the test would pass or fail for the wrong reason.
  adb install -r "$APK" >/dev/null

  adb logcat -c
  adb shell am start -n "$PACKAGE/.MainActivity" >/dev/null

  local deadline=$((SECONDS + 90)) line=""
  while (( SECONDS < deadline )); do
    line="$(adb logcat -d | grep -o "$MARKER.*" | tail -1 || true)"
    [[ -n "$line" ]] && break
    sleep 2
  done

  if [[ -z "$line" ]]; then
    echo "==> $label: FAILED (no result within 90s; app may have crashed)" >&2
    adb logcat -d | tail -30 >&2
    return 1
  fi

  echo "==> $label: $line"
  [[ "$line" == *"$MARKER PASS"* ]]
}

# Phase A: write tokens the way SDK 3.x did. dependency_overrides is what lets the
# example resolve 9.2.4 even though the SDK under test declares ^10.3.1. Starts from a
# clean install so a stale data directory cannot make the test pass spuriously.
cat >> "$PUBSPEC" <<'OVERRIDE'

dependency_overrides:
  flutter_secure_storage: 9.2.4
OVERRIDE
(cd "$EXAMPLE" && flutter pub get >/dev/null)
run_phase "phase A (flutter_secure_storage 9.2.4, writes v9 data)" \
  tool_migration/migration_write_main.dart fresh

# Phase B: drop the override so the SDK's own ^10.3.1 constraint resolves, then read the
# same keys back through the class 4.0 ships -- over the data directory phase A left.
cp "$BACKUP" "$PUBSPEC"
cp "$LOCK_BACKUP" "$PUBSPEC_LOCK"
(cd "$EXAMPLE" && flutter pub get >/dev/null)
run_phase "phase B (flutter_secure_storage 10.x, reads after upgrade)" \
  tool_migration/migration_read_main.dart keep

echo
echo "==> token migration verified: SDK 3.x tokens survive the upgrade to 4.0"
