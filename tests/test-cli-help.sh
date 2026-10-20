#!/usr/bin/env bash
# Test: shizuku help lists the mandatory verbs.
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SHIZUKU="$SCRIPT_DIR/../src/bin/shizuku"

PASS=0; FAIL=0

[ -x "$SHIZUKU" ] || chmod +x "$SHIZUKU"

echo "--- test: help lists verbs ---"
out="$(bash "$SHIZUKU" help 2>&1 || true)"

for v in install doctor rish info open stop exec shell version uninstall sui wireless usb-loopback keepalive pm-install start-daemon adb-connect wait aliases help; do
    if echo "$out" | grep -q "$v"; then
        echo "OK: verb '$v' listed"
    else
        echo "FAIL: verb '$v' NOT listed"; FAIL=$((FAIL+1))
    fi
done

echo "--- test: install mentions --source latest ---"
if echo "$out" | grep -q -- '--source latest'; then
    echo "OK: --source latest mentioned in help"
else
    echo "FAIL: --source latest not mentioned"; FAIL=$((FAIL+1))
fi

echo "--- test: help returns 0 or lists without error ---"
if echo "$out" | grep -qi "error\|not found"; then
    echo "FAIL: help produced an error"; FAIL=$((FAIL+1))
else
    echo "OK: help without error"
fi

echo "--- test: doctor on host does not recurse (timeout 2s) ---"
out_doc="$(timeout 2 bash "$SHIZUKU" doctor 2>&1 || true)"
rc_doc=$?
if echo "$out_doc" | grep -qi "recurs\|infinito\|loop"; then
    echo "FAIL: doctor suspected of recursion"; FAIL=$((FAIL+1))
elif [ $rc_doc -eq 124 ]; then
    echo "FAIL: doctor exceeded 2s timeout (possible loop)"; FAIL=$((FAIL+1))
else
    echo "OK: doctor finished without recursion (rc=$rc_doc)"
fi

echo "--- test: shebang is not #!/usr/bin/env (Android has no /usr/bin/env) ---"
for f in "$SHIZUKU" "$SCRIPT_DIR/../src/bin/shk"; do
    first="$(head -1 "$f")"
    if [ "$first" = "#!/usr/bin/env bash" ]; then
        echo "FAIL: $f still uses #!/usr/bin/env bash"; FAIL=$((FAIL+1))
    else
        echo "OK: $f shebang=$first"
    fi
done

if [ $FAIL -eq 0 ]; then echo "RESULT: cli-help tests PASSED"; else echo "RESULT: $FAIL FAILURE(S)"; fi
exit $FAIL
