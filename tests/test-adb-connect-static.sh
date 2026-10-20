#!/usr/bin/env bash
# Static test: adb-connect plugin.
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PLUGIN="$SCRIPT_DIR/../src/plugins/adb-connect.sh"

# Sourcing paths.sh inherits 'set -euo pipefail' from extract-apk.sh; we disable it to manage PASS/FAIL manually.
set +e
set +u

PASS=0; FAIL=0

[ -f "$PLUGIN" ] || { echo "FAIL: plugin not found"; exit 1; }

echo "--- test: contains CONNECT_HOST=127.0.0.1 ---"
grep -q 'CONNECT_HOST="127.0.0.1"' "$PLUGIN" && { echo "OK: fixed host 127.0.0.1"; PASS=$((PASS+1)); } || { echo "FAIL: host is not 127.0.0.1"; FAIL=$((FAIL+1)); }

echo "--- test: contains st_adb connect ---"
grep -q 'st_adb connect' "$PLUGIN" && { echo "OK: st_adb connect present"; PASS=$((PASS+1)); } || { echo "FAIL: st_adb connect missing"; FAIL=$((FAIL+1)); }

echo "--- test: contains st_adb pair ---"
grep -q 'st_adb pair' "$PLUGIN" && { echo "OK: st_adb pair present"; PASS=$((PASS+1)); } || { echo "FAIL: st_adb pair missing"; FAIL=$((FAIL+1)); }

echo "--- test: contains st_adb disconnect ---"
grep -q 'st_adb disconnect' "$PLUGIN" && { echo "OK: st_adb disconnect present"; PASS=$((PASS+1)); } || { echo "FAIL: st_adb disconnect missing"; FAIL=$((FAIL+1)); }

echo "--- test: contains st_adb devices ---"
grep -q 'st_adb devices' "$PLUGIN" && { echo "OK: st_adb devices present"; PASS=$((PASS+1)); } || { echo "FAIL: st_adb devices missing"; FAIL=$((FAIL+1)); }

echo "--- test: contains wait-for-device ---"
grep -q 'wait-for-device' "$PLUGIN" && { echo "OK: wait-for-device present"; PASS=$((PASS+1)); } || { echo "FAIL: wait-for-device missing"; FAIL=$((FAIL+1)); }

echo "--- test: contains toggle_adb_wireless (wf) ---"
grep -q 'toggle_adb_wireless' "$PLUGIN" && { echo "OK: toggle_adb_wireless present"; PASS=$((PASS+1)); } || { echo "FAIL: toggle_adb_wireless missing"; FAIL=$((FAIL+1)); }

echo "--- test: does NOT contain adb tcpip ---"
if grep -Eq 'adb tcpip|tcpip ' "$PLUGIN"; then
    echo "FAIL: contains adb tcpip (forbidden)"; FAIL=$((FAIL+1))
else
    echo "OK: no adb tcpip"; PASS=$((PASS+1)); fi

echo "--- test: does NOT contain bare adb (must be st_adb) ---"
if grep -Eq '\badb (connect|pair|disconnect|devices|start-server|shell)' "$PLUGIN"; then
    echo "FAIL: contains bare adb (must be st_adb)"; FAIL=$((FAIL+1))
else
    echo "OK: every adb call goes through st_adb"; PASS=$((PASS+1)); fi

echo "--- test: CONNECT_HOST is 127.0.0.1 and every st_adb connect uses the variable ---"
grep -q 'CONNECT_HOST="127.0.0.1"' "$PLUGIN" || { echo "FAIL: CONNECT_HOST is not 127.0.0.1"; FAIL=$((FAIL+1)); }
if grep -Eq 'st_adb connect [^"$]' "$PLUGIN"; then
    echo "FAIL: st_adb connect with a non-variable literal host"; FAIL=$((FAIL+1))
else
    echo "OK: st_adb connect always uses the variable"; PASS=$((PASS+1)); fi

if [ $FAIL -eq 0 ]; then echo "RESULT: adb-connect-static tests PASSED"; else echo "RESULT: $FAIL FAILURE(S)"; fi
exit $FAIL
