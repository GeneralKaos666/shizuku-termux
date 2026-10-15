#!/usr/bin/env bash
# Teste doctor estático: mock de `pm` no PATH, testa DEX missing=6 e DEX writable=3.
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
. "$SCRIPT_DIR/../src/lib/paths.sh"
. "$SCRIPT_DIR/../src/lib/doctor.sh"

PASS=0; FAIL=0

# --- fake `pm` que retorna APK Shizuku instalado ---
FAKEBIN="/tmp/fakebin_doctor"
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

export PREFIX="/tmp/doctor_test_prefix"
LIBDIR="$(st_prefix_lib)"
mkdir -p "$LIBDIR"

echo "--- teste 1: DEX ausente → exit 6 ---"
rm -f "$LIBDIR/rish_shizuku.dex" "$LIBDIR/rish"
rc=0; st_doctor >/tmp/doc1.out 2>&1 || rc=$?
if [ "${rc:-}" = "6" ]; then echo "OK: exit 6 (DEX ausente)"; else echo "FALHA: esperado 6, obteve ${rc:-} (veja /tmp/doc1.out)"; FAIL=$((FAIL+1)); fi

echo "--- teste 2: DEX gravável → exit 3 ---"
echo 'dex' > "$LIBDIR/rish_shizuku.dex"
chmod 644 "$LIBDIR/rish_shizuku.dex"
rc=0; st_doctor >/tmp/doc2.out 2>&1 || rc=$?
if [ "${rc:-}" = "3" ]; then echo "OK: exit 3 (DEX gravável)"; else echo "FALHA: esperado 3, obteve ${rc:-} (veja /tmp/doc2.out)"; FAIL=$((FAIL+1)); fi

echo "--- teste 3: DEX OK + launcher → exit 0 (device pulado no host) ---"
chmod 400 "$LIBDIR/rish_shizuku.dex"
echo '#!/system/bin/sh' > "$LIBDIR/rish"
chmod 755 "$LIBDIR/rish"
rc=0; st_doctor >/tmp/doc3.out 2>&1 || rc=$?
if [ "${rc:-}" = "0" ]; then echo "OK: exit 0 (saudável)"; else echo "FALHA: esperado 0, obteve ${rc:-} (veja /tmp/doc3.out)"; FAIL=$((FAIL+1)); fi

echo "--- teste 4: st_app_id padrão com.termux ---"
unset TERMUX_APP__PACKAGE_NAME
aid="$(st_app_id)"
[ "$aid" = "com.termux" ] && echo "OK: app_id padrão com.termux" || { echo "FALHA: app_id=$aid"; FAIL=$((FAIL+1)); }

echo "--- teste 5: st_app_id usa TERMUX_APP__PACKAGE_NAME ---"
export TERMUX_APP__PACKAGE_NAME="com.termux.play"
aid="$(st_app_id)"
[ "$aid" = "com.termux.play" ] && echo "OK: app_id=$aid" || { echo "FALHA: app_id=$aid"; FAIL=$((FAIL+1)); }

if [ $FAIL -eq 0 ]; then echo "RESULTADO: TESTES doctor-static PASSARAM"; else echo "RESULTADO: $FAIL FALHA(S)"; fi
exit $FAIL
