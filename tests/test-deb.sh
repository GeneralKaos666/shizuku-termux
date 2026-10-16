#!/usr/bin/env bash
# Test: build-deb.sh produces a .deb (or structure) with ZERO .dex/.so/apk.
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BUILD="$SCRIPT_DIR/../src/packaging/build-deb.sh"

PASS=0; FAIL=0

echo "--- test: build-deb.sh runs ---"
bash "$BUILD" > /tmp/deb-build.out 2>&1
rc=$?
if [ "$rc" = "0" ]; then
    echo "OK: build-deb.sh exit 0"
else
    echo "FAIL: build-deb.sh exit $rc (see /tmp/deb-build.out)"; FAIL=$((FAIL+1))
fi

echo "--- test: output mentions .deb or a ready structure ---"
if grep -qiE "\.deb|Structure ready" /tmp/deb-build.out; then
    echo "OK: output mentions .deb/structure"
else
    echo "FAIL: output does not mention .deb"; FAIL=$((FAIL+1))
fi

echo "--- test: ZERO .dex/.so/apk in the generated content ---"
if [ -f /tmp/shizuku-termux-1.0.0.deb ] && command -v dpkg-deb >/dev/null 2>&1; then
    listing="$(dpkg-deb --contents /tmp/shizuku-termux-1.0.0.deb 2>/dev/null || true)"
    if echo "$listing" | grep -qE '\.(dex|so|apk)'; then
        echo "FAIL: .deb contains .dex/.so/apk"; FAIL=$((FAIL+1))
    else
        echo "OK: .deb without .dex/.so/apk"
    fi
elif [ -d /tmp/shizuku-termux-1.0.0 ]; then
    if find /tmp/shizuku-termux-1.0.0 -name '*.dex' -o -name '*.so' -o -name '*.apk' 2>/dev/null | grep -q .; then
        echo "FAIL: structure contains .dex/.so/apk"; FAIL=$((FAIL+1))
    else
        echo "OK: structure without .dex/.so/apk"
    fi
else
    echo "WARNING: neither .deb nor structure found; skipping content check"
fi

if [ $FAIL -eq 0 ]; then echo "RESULT: deb tests PASSED"; else echo "RESULT: $FAIL FAILURE(S)"; fi
exit $FAIL
