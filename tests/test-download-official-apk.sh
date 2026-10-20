#!/usr/bin/env bash
# Test: st_apk_url_from_release_json with a JSON fixture (no real network).
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
. "$SCRIPT_DIR/../src/lib/paths.sh"
. "$SCRIPT_DIR/../src/lib/extract-apk.sh"

# The source above inherits 'set -e' from extract-apk.sh; we disable it because we manage PASS/FAIL manually.
set +e

PASS=0; FAIL=0

# ── Test 1: JSON fixture with a valid .apk asset ──
JSON1="$(mktemp)"
cat > "$JSON1" <<'JSON'
{
  "tag_name": "v13.6.0",
  "assets": [
    {"name": "Shizuku.apk", "browser_download_url": "https://github.com/RikkaApps/Shizuku/releases/download/v13.6.0/Shizuku.apk"},
    {"name": "rish", "browser_download_url": "https://github.com/RikkaApps/Shizuku/releases/download/v13.6.0/rish"}
  ]
}
JSON

url="$(st_apk_url_from_release_json "$JSON1")"
[ "$url" = "https://github.com/RikkaApps/Shizuku/releases/download/v13.6.0/Shizuku.apk" ] && {
    echo "OK: extracted .apk URL from JSON"; PASS=$((PASS+1))
} || { echo "FAIL: extracted URL is incorrect: $url"; FAIL=$((FAIL+1)); }

# ── Test 2: JSON without a .apk asset (only a fake 'rish') ──
JSON2="$(mktemp)"
cat > "$JSON2" <<'JSON'
{
  "tag_name": "v13.6.0",
  "assets": [
    {"name": "rish", "browser_download_url": "https://github.com/RikkaApps/Shizuku/releases/download/v13.6.0/rish"}
  ]
}
JSON

url2="$(st_apk_url_from_release_json "$JSON2")"
[ -z "$url2" ] && {
    echo "OK: rejected JSON without a .apk asset"; PASS=$((PASS+1))
} || { echo "FAIL: should not have extracted .apk from JSON without asset"; FAIL=$((FAIL+1)); }

# ── Test 3: functions exist ──
command -v st_apk_url_from_release_json >/dev/null 2>&1 && {
    echo "OK: function st_apk_url_from_release_json exists"; PASS=$((PASS+1))
} || { echo "FAIL: function not found"; FAIL=$((FAIL+1)); }

command -v st_download_official_apk >/dev/null 2>&1 && {
    echo "OK: function st_download_official_apk exists"; PASS=$((PASS+1))
} || { echo "FAIL: function not found"; FAIL=$((FAIL+1)); }

# ── Test 4: --source reads the next argument and compares with 'latest' ──
SHIZUKU_SRC="$SCRIPT_DIR/../src/bin/shizuku"
grep -q -- '--source)' "$SHIZUKU_SRC" && {
    echo "OK: case --source present in the CLI"; PASS=$((PASS+1))
} || { echo "FAIL: case --source missing"; FAIL=$((FAIL+1)); }

# The case --source must shift and compare $1 with 'latest' (not source_latest=1 without reading the argument)
if grep -A3 -- '--source)' "$SHIZUKU_SRC" | grep -q 'shift' && grep -A3 -- '--source)' "$SHIZUKU_SRC" | grep -q 'case "\$1"'; then
    echo "OK: --source reads the next argument after shift"; PASS=$((PASS+1))
else
    echo "FAIL: --source does not read the next argument"; FAIL=$((FAIL+1)); fi

# Rejects 'source_latest=1; shift' without reading the argument (broken old pattern)
if grep -A1 -- '--source)' "$SHIZUKU_SRC" | grep -q 'source_latest=1'; then
    echo "FAIL: --source still sets source_latest=1 without reading the argument"; FAIL=$((FAIL+1))
else
    echo "OK: --source does not set source_latest without reading the argument"; PASS=$((PASS+1)); fi

rm -f "$JSON1" "$JSON2"

if [ $FAIL -eq 0 ]; then echo "RESULT: download-official-apk tests PASSED"; else echo "RESULT: $FAIL FAILURE(S)"; fi
exit $FAIL
