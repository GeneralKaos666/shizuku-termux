#!/usr/bin/env bash
# Static doctor test: mock `pm` on PATH, test DEX missing=6 and DEX writable=3.
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TMP="${TMPDIR:-/tmp}"
. "$SCRIPT_DIR/../src/lib/paths.sh"
. "$SCRIPT_DIR/../src/lib/doctor.sh"

PASS=0; FAIL=0

# --- fake `pm` that returns an installed Shizuku APK ---
FAKEBIN="$TMP/fakebin_doctor"
mkdir -p "$FAKEBIN"
cat > "$FAKEBIN/pm" <<'PM'
#!/usr/bin/env bash
if [ "$1" = "path" ] && [ "$2" = "moe.shizuku.privileged.api" ]; then
    echo "package:/data/app/moe.shizuku.privileged.apk"
    exit 0
fi
exit 1
PM
chmod +x "$FAKEBIN/pm"
export PATH="$FAKEBIN:$PATH"

export PREFIX="$TMP/doctor_test_prefix"
LIBDIR="$(st_prefix_lib)"
mkdir -p "$LIBDIR"

echo "--- test 1: DEX missing → exit 6 ---"
rm -f "$LIBDIR/rish_shizuku.dex" "$LIBDIR/rish"
rc=0; st_doctor >"$TMP"/doc1.out 2>&1 || rc=$?
if [ "${rc:-}" = "6" ]; then echo "OK: exit 6 (DEX missing)"; else echo "FAIL: expected 6, got ${rc:-} (see "$TMP"/doc1.out)"; FAIL=$((FAIL+1)); fi

echo "--- test 2: DEX writable → exit 3 ---"
echo 'dex' > "$LIBDIR/rish_shizuku.dex"
chmod 644 "$LIBDIR/rish_shizuku.dex"
rc=0; st_doctor >"$TMP"/doc2.out 2>&1 || rc=$?
if [ "${rc:-}" = "3" ]; then echo "OK: exit 3 (DEX writable)"; else echo "FAIL: expected 3, got ${rc:-} (see "$TMP"/doc2.out)"; FAIL=$((FAIL+1)); fi

echo "--- test 3: DEX OK + launcher → exit 0 (device check skipped on host) ---"
chmod 400 "$LIBDIR/rish_shizuku.dex"
echo '#!/system/bin/sh' > "$LIBDIR/rish"
chmod 755 "$LIBDIR/rish"
rc=0; st_doctor >"$TMP"/doc3.out 2>&1 || rc=$?
if [ "${rc:-}" = "0" ]; then echo "OK: exit 0 (healthy)"; else echo "FAIL: expected 0, got ${rc:-} (see "$TMP"/doc3.out)"; FAIL=$((FAIL+1)); fi

echo "--- test 4: default st_app_id com.termux ---"
unset TERMUX_APP__PACKAGE_NAME
aid="$(st_app_id)"
[ "$aid" = "com.termux" ] && echo "OK: default app_id com.termux" || { echo "FAIL: app_id=$aid"; FAIL=$((FAIL+1)); }

echo "--- test 5: st_app_id uses TERMUX_APP__PACKAGE_NAME ---"
export TERMUX_APP__PACKAGE_NAME="com.termux.play"
aid="$(st_app_id)"
[ "$aid" = "com.termux.play" ] && echo "OK: app_id=$aid" || { echo "FAIL: app_id=$aid"; FAIL=$((FAIL+1)); }

if [ $FAIL -eq 0 ]; then echo "RESULT: doctor-static tests PASSED"; else echo "RESULT: $FAIL FAILURE(S)"; fi
exit $FAIL
