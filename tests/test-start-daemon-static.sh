#!/usr/bin/env bash
# Static test: start-daemon plugin contains official start.sh, libshizuku.so and --apk=.
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PLUGIN="$SCRIPT_DIR/../src/plugins/start-daemon.sh"

PASS=0; FAIL=0

[ -f "$PLUGIN" ] || { echo "FAIL: plugin not found"; exit 1; }

echo "--- test: contains official start.sh ---"
grep -q 'start.sh' "$PLUGIN" && { echo "OK: start.sh present"; PASS=$((PASS+1)); } || { echo "FAIL: start.sh missing"; FAIL=$((FAIL+1)); }

echo "--- test: contains st_adb shell pm path to locate the APK ---"
grep -q 'st_adb shell pm path moe.shizuku.privileged.api' "$PLUGIN" && { echo "OK: st_adb shell pm path present"; PASS=$((PASS+1)); } || { echo "FAIL: st_adb shell pm path missing"; FAIL=$((FAIL+1)); }

echo "--- test: contains libshizuku.so ---"
grep -q 'libshizuku.so' "$PLUGIN" && { echo "OK: libshizuku.so present"; PASS=$((PASS+1)); } || { echo "FAIL: libshizuku.so missing"; FAIL=$((FAIL+1)); }

echo "--- test: contains --apk= ---"
grep -q -- '--apk=' "$PLUGIN" && { echo "OK: --apk= present"; PASS=$((PASS+1)); } || { echo "FAIL: --apk= missing"; FAIL=$((FAIL+1)); }

echo "--- test: does NOT contain st_adb tcpip / st_adb pair / st_adb connect 127.0.0.1 ---"
if grep -qE 'st_adb (tcpip|pair|connect 127\.0\.0\.1)' "$PLUGIN"; then
    echo "FAIL: contains forbidden network commands"; FAIL=$((FAIL+1))
else
    echo "OK: no forbidden network commands"; PASS=$((PASS+1)); fi

echo "--- test: does NOT contain bare adb (must be st_adb) ---"
if grep -Eq '\badb (shell|pm|dumpsys|test)' "$PLUGIN"; then
    echo "FAIL: contains bare adb (must be st_adb)"; FAIL=$((FAIL+1))
else
    echo "OK: every adb call goes through st_adb"; PASS=$((PASS+1)); fi

echo "--- test: does NOT contain pm install / su / setenforce ---"
if grep -qE 'pm install|su |setenforce' "$PLUGIN"; then
    echo "FAIL: contains forbidden commands"; FAIL=$((FAIL+1))
else
    echo "OK: no forbidden commands"; PASS=$((PASS+1)); fi

if [ $FAIL -eq 0 ]; then echo "RESULT: start-daemon-static tests PASSED"; else echo "RESULT: $FAIL FAILURE(S)"; fi
exit $FAIL
