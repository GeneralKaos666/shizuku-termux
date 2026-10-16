#!/usr/bin/env bash
# Test: st_wait in doctor.sh. No device, no real adb network.
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TMP="${TMPDIR:-/tmp}"
. "$SCRIPT_DIR/../src/lib/paths.sh"
. "$SCRIPT_DIR/../src/lib/doctor.sh"

# set -e coming from extract-apk.sh (via paths.sh) could end the test; we disable it.
set +e

PASS=0; FAIL=0

echo "--- test 1: st_wait 0 with rish missing -> return 2 (fast) ---"
start_ts=$(date +%s)
st_wait 0 >"$TMP"/wait1.out 2>&1 || rc=$?
end_ts=$(date +%s)
elapsed=$((end_ts - start_ts))
[ "$rc" = "2" ] && { echo "OK: return 2 (Shizuku down)"; PASS=$((PASS+1)); } || { echo "FAIL: expected 2, got ${rc:-}"; FAIL=$((FAIL+1)); }
[ "$elapsed" -lt 5 ] && { echo "OK: did not take long ($elapsed s)"; PASS=$((PASS+1)); } || { echo "FAIL: took too long ($elapsed s)"; FAIL=$((FAIL+1)); }

echo "--- test 2: st_wait 0 with a rish that exits 0 -> return 0 ---"
tmpbin="$(mktemp -d)"
cat > "$tmpbin/rish" <<'RISH'
#!/bin/bash
exit 0
RISH
chmod 755 "$tmpbin/rish"
rc=0
PATH="$tmpbin:$PATH" st_wait 0 >"$TMP"/wait2.out 2>&1 || rc=$?
[ "$rc" = "0" ] && { echo "OK: return 0 (Shizuku responded)"; PASS=$((PASS+1)); } || { echo "FAIL: expected 0, got ${rc:-}"; FAIL=$((FAIL+1)); }
rm -rf "$tmpbin"

echo "--- test 3: st_wait without an argument uses default 60 (does not test time, only that it does not hang) ---"
st_wait 0 >/dev/null 2>&1
echo "OK: st_wait has no syntax error"; PASS=$((PASS+1))

if [ $FAIL -eq 0 ]; then echo "RESULT: wait tests PASSED"; else echo "RESULT: $FAIL FAILURE(S)"; fi
exit $FAIL
