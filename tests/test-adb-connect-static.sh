#!/usr/bin/env bash
# Teste estático: plugin adb-connect.
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PLUGIN="$SCRIPT_DIR/../src/plugins/adb-connect.sh"

# O source de paths.sh herda 'set -euo pipefail' de extract-apk.sh; desligamos para gerenciar PASS/FAIL manualmente.
set +e
set +u

PASS=0; FAIL=0

[ -f "$PLUGIN" ] || { echo "FALHA: plugin não encontrado"; exit 1; }

echo "--- teste: contém CONNECT_HOST=127.0.0.1 ---"
grep -q 'CONNECT_HOST="127.0.0.1"' "$PLUGIN" && { echo "OK: host fixo 127.0.0.1"; PASS=$((PASS+1)); } || { echo "FALHA: host nao e 127.0.0.1"; FAIL=$((FAIL+1)); }

echo "--- teste: contém st_adb connect ---"
grep -q 'st_adb connect' "$PLUGIN" && { echo "OK: st_adb connect presente"; PASS=$((PASS+1)); } || { echo "FALHA: st_adb connect ausente"; FAIL=$((FAIL+1)); }

echo "--- teste: contém st_adb pair ---"
grep -q 'st_adb pair' "$PLUGIN" && { echo "OK: st_adb pair presente"; PASS=$((PASS+1)); } || { echo "FALHA: st_adb pair ausente"; FAIL=$((FAIL+1)); }

echo "--- teste: contém st_adb disconnect ---"
grep -q 'st_adb disconnect' "$PLUGIN" && { echo "OK: st_adb disconnect presente"; PASS=$((PASS+1)); } || { echo "FALHA: st_adb disconnect ausente"; FAIL=$((FAIL+1)); }

echo "--- teste: contém st_adb devices ---"
grep -q 'st_adb devices' "$PLUGIN" && { echo "OK: st_adb devices presente"; PASS=$((PASS+1)); } || { echo "FALHA: st_adb devices ausente"; FAIL=$((FAIL+1)); }

echo "--- teste: contém wait-for-device ---"
grep -q 'wait-for-device' "$PLUGIN" && { echo "OK: wait-for-device presente"; PASS=$((PASS+1)); } || { echo "FALHA: wait-for-device ausente"; FAIL=$((FAIL+1)); }

echo "--- teste: contém toggle_adb_wireless (wf) ---"
grep -q 'toggle_adb_wireless' "$PLUGIN" && { echo "OK: toggle_adb_wireless presente"; PASS=$((PASS+1)); } || { echo "FALHA: toggle_adb_wireless ausente"; FAIL=$((FAIL+1)); }

echo "--- teste: NAO contem adb tcpip ---"
if grep -Eq 'adb tcpip|tcpip ' "$PLUGIN"; then
    echo "FALHA: contem adb tcpip (proibido)"; FAIL=$((FAIL+1))
else
    echo "OK: sem adb tcpip"; PASS=$((PASS+1)); fi

echo "--- teste: NAO contem adb nu (deve ser st_adb) ---"
if grep -Eq '\badb (connect|pair|disconnect|devices|start-server|shell)' "$PLUGIN"; then
    echo "FALHA: contem adb nu (deve ser st_adb)"; FAIL=$((FAIL+1))
else
    echo "OK: todo adb eh via st_adb"; PASS=$((PASS+1)); fi

echo "--- teste: CONNECT_HOST e' 127.0.0.1 e todo st_adb connect usa variavel ---"
grep -q 'CONNECT_HOST="127.0.0.1"' "$PLUGIN" || { echo "FALHA: CONNECT_HOST nao e 127.0.0.1"; FAIL=$((FAIL+1)); }
if grep -Eq 'st_adb connect [^"$]' "$PLUGIN"; then
    echo "FALHA: ha st_adb connect com host literal nao-variavel"; FAIL=$((FAIL+1))
else
    echo "OK: st_adb connect sempre usa variavel"; PASS=$((PASS+1)); fi

if [ $FAIL -eq 0 ]; then echo "RESULTADO: TESTES adb-connect-static PASSARAM"; else echo "RESULTADO: $FAIL FALHA(S)"; fi
exit $FAIL
