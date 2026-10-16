#!/usr/bin/env bash
# Test: rish generated from rish.in has no PKG, has ShizukuShellLoader and a writable-DEX check→exit 3.
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TMP="${TMPDIR:-/tmp}"
SRC="$SCRIPT_DIR/../src/bin/rish.in"
GEN="$TMP/rish_generated.sh"
export PREFIX="${PREFIX:-/data/data/com.termux/files/usr}"

PASS=0; FAIL=0

[ -f "$SRC" ] || { echo "FAIL: rish.in not found"; exit 1; }

# Generate: substitute placeholders
sed -e 's/@APP_ID@/com.termux/g' \
    -e "s|@DEX@|$PREFIX/lib/shizuku-termux/rish_shizuku.dex|g" \
    -e 's|@LIB@||g' \
    -e 's|@LOADER@|rikka.shizuku.shell.ShizukuShellLoader|g' \
    "$SRC" > "$GEN"

echo "--- test: placeholder @APP_ID@ substituted (no PKG left) ---"
if grep -q '@APP_ID@' "$GEN"; then
    echo "FAIL: placeholder @APP_ID@ not substituted"; FAIL=$((FAIL+1))
elif grep -q 'APP_ID="PKG"' "$GEN"; then
    echo "FAIL: APP_ID stayed as literal PKG"; FAIL=$((FAIL+1))
else
    echo "OK: APP_ID resolved (no PKG placeholder)"
fi

echo "--- test: contains com.termux as app id ---"
if grep -q 'com.termux' "$GEN"; then
    echo "OK: contains com.termux"
else
    echo "FAIL: no com.termux"; FAIL=$((FAIL+1))
fi

echo "--- test: contains FQCN class rikka.shizuku.shell.ShizukuShellLoader ---"
if grep -Fq 'rikka.shizuku.shell.ShizukuShellLoader' "$GEN"; then
    echo "OK: Rikka FQCN class present"
else
    echo "FAIL: no rikka.shizuku.shell.ShizukuShellLoader"; FAIL=$((FAIL+1))
fi

echo "--- test: refuses libsu (topjohnwu) ---"
if grep -Fq 'com.topjohnwu' "$GEN"; then
    echo "FAIL: contains libsu class (topjohnwu)"; FAIL=$((FAIL+1))
else
    echo "OK: no libsu (topjohnwu)"
fi

echo "--- test: contains -Djava.class.path= (DEX injected) ---"
if grep -F -- '-Djava.class.path=' "$GEN"; then
    echo "OK: contains -Djava.class.path="
else
    echo "FAIL: no -Djava.class.path="; FAIL=$((FAIL+1))
fi

echo "--- test: contains app_process /system/bin ---"
if grep -q '/system/bin/app_process' "$GEN"; then
    echo "OK: contains app_process /system/bin"
else
    echo "FAIL: no app_process /system/bin"; FAIL=$((FAIL+1))
fi

echo "--- test: contains writable-DEX check → exit 3 ---"
if grep -q 'exit 3' "$GEN"; then
    echo "OK: contains exit 3"
else
    echo "FAIL: no exit 3"; FAIL=$((FAIL+1))
fi

if [ $FAIL -eq 0 ]; then echo "RESULT: rish-gen tests PASSED"; else echo "RESULT: $FAIL FAILURE(S)"; fi
exit $FAIL
