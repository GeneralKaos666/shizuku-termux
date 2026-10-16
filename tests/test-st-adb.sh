#!/usr/bin/env bash
# Test: st_adb_bin / st_adb with and without ST_ADB, no real network.
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
. "$SCRIPT_DIR/../src/lib/paths.sh"

# The source above inherits 'set -euo pipefail' from extract-apk.sh; we disable it to manage PASS/FAIL manually.
set +e
set +u

PASS=0; FAIL=0

echo "--- test 1: ST_ADB pointing to a nonexistent stub → st_adb_bin fails ---"
tmpbin0="$(mktemp -d)"
ST_ADB="/tmp/does-not-exist-adb" PATH="$tmpbin0" st_adb_bin >/tmp/stadb1.out 2>&1 || rc=$?
rc=${rc:-0}
[ "$rc" = "1" ] && { echo "OK: st_adb_bin returns 1 without a valid ST_ADB"; PASS=$((PASS+1)); } || { echo "FAIL: expected 1, got ${rc:-}"; FAIL=$((FAIL+1)); }
rm -rf "$tmpbin0"

echo "--- test 2: ST_ADB pointing to an executable stub → st_adb uses that path ---"
tmpbin="$(mktemp -d)"
cat > "$tmpbin/adb-stub" <<'ADB'
#!/bin/bash
echo "stub-adb: $*"
ADB
chmod 755 "$tmpbin/adb-stub"
out="$(ST_ADB="$tmpbin/adb-stub" st_adb version 2>&1)" || rc=$?
echo "$out" | grep -q "stub-adb: version" && { echo "OK: st_adb uses ST_ADB ($out)"; PASS=$((PASS+1)); } || { echo "FAIL: output=$out rc=$rc"; FAIL=$((FAIL+1)); }
rm -rf "$tmpbin"

echo "--- test 3: no ST_ADB and no adb on PATH → message contains github.com/rianprei/termux-adb ---"
# Create an empty PATH without adb
tmpbin2="$(mktemp -d)"
out="$(PATH="$tmpbin2" st_adb_bin 2>&1)" || rc=$?
echo "$out" | grep -q "github.com/rianprei/termux-adb" && { echo "OK: message mentions github.com/rianprei/termux-adb"; PASS=$((PASS+1)); } || { echo "FAIL: output=$out rc=$rc"; FAIL=$((FAIL+1)); }
rm -rf "$tmpbin2"

if [ $FAIL -eq 0 ]; then echo "RESULT: st-adb tests PASSED"; else echo "RESULT: $FAIL FAILURE(S)"; fi
exit $FAIL
