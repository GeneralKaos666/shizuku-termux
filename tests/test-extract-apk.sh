#!/usr/bin/env bash
# Test: st_extract_from_apk with a local zip fixture (no network).
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
. "$SCRIPT_DIR/../src/lib/paths.sh"
. "$SCRIPT_DIR/../src/lib/extract-apk.sh"

PASS=0; FAIL=0

# Create a zip fixture with assets/rish and assets/rish_shizuku.dex
FIXTURE="/tmp/shizuku_fixture.zip"
rm -f "$FIXTURE"
tmpd="$(mktemp -d)"
mkdir -p "$tmpd/assets"
echo '#!/system/bin/sh' > "$tmpd/assets/rish"
echo 'DEX_PLACEHOLDER' > "$tmpd/assets/rish_shizuku.dex"
# x86_64 ABI on the host → no lib in the fixture → warning only.
python3 -c "import zipfile,os; z=zipfile.ZipFile('$FIXTURE','w'); z.write('$tmpd/assets/rish','assets/rish'); z.write('$tmpd/assets/rish_shizuku.dex','assets/rish_shizuku.dex'); z.close()"

DEST="$(mktemp -d)"
trap 'rm -rf "$tmpd" "$DEST"' RETURN

echo "--- test: extraction with correct modes ---"
if st_extract_from_apk "$FIXTURE" "$DEST"; then
    echo "OK: extraction returned 0"
else
    echo "FAIL: extraction returned !=0"; FAIL=$((FAIL+1))
fi

if [ -f "$DEST/rish" ] && [ -f "$DEST/rish_shizuku.dex" ]; then
    echo "OK: rish and dex present"
else
    echo "FAIL: files missing"; FAIL=$((FAIL+1))
fi

# Check modes: rish 755, dex 400
rish_mode="$(stat -c '%a' "$DEST/rish" 2>/dev/null || stat -f '%Lp' "$DEST/rish")"
dex_mode="$(stat -c '%a' "$DEST/rish_shizuku.dex" 2>/dev/null || stat -f '%Lp' "$DEST/rish_shizuku.dex")"
[ "$rish_mode" = "755" ] || { echo "FAIL: rish mode=$rish_mode (expected 755)"; FAIL=$((FAIL+1)); }
[ "$dex_mode" = "400" ] || { echo "FAIL: dex mode=$dex_mode (expected 400)"; FAIL=$((FAIL+1)); }

echo "--- test: refuses APK without assets ---"
badzip="/tmp/bad.zip"
echo 'not an apk' > "$badzip"
if st_extract_from_apk "$badzip" "$DEST" 2>/dev/null; then
    echo "FAIL: should have refused an invalid APK"; FAIL=$((FAIL+1))
else
    echo "OK: invalid APK refused"
fi

echo "--- test: refuses a missing APK ---"
if st_extract_from_apk "/tmp/does-not-exist.apk" "$DEST" 2>/dev/null; then
    echo "FAIL: should have refused a missing APK"; FAIL=$((FAIL+1))
else
    echo "OK: missing APK refused"
fi

if [ $FAIL -eq 0 ]; then echo "RESULT: extract-apk tests PASSED"; else echo "RESULT: $FAIL FAILURE(S)"; fi
exit $FAIL
