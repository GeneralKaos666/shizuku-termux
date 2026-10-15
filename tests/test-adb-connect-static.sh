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

echo "--- teste: contém adb connect ---"
grep -q 'adb connect' "$PLUGIN" && { echo "OK: adb connect presente"; PASS=$((PASS+1)); } || { echo "FALHA: adb connect ausente"; FAIL=$((FAIL+1)); }

echo "--- teste: contém adb pair ---"
grep -q 'adb pair' "$PLUGIN" && { echo "OK: adb pair presente"; PASS=$((PASS+1)); } || { echo "FALHA: adb pair ausente"; FAIL=$((FAIL+1)); }

echo "--- teste: contém adb disconnect ---"
grep -q 'adb disconnect' "$PLUGIN" && { echo "OK: adb disconnect presente"; PASS=$((PASS+1)); } || { echo "FALHA: adb disconnect ausente"; FAIL=$((FAIL+1)); }

echo "--- teste: contém wait-for-device ---"
grep -q 'wait-for-device' "$PLUGIN" && { echo "OK: wait-for-device presente"; PASS=$((PASS+1)); } || { echo "FALHA: wait-for-device ausente"; FAIL=$((FAIL+1)); }

echo "--- teste: contém toggle_adb_wireless (wf) ---"
grep -q 'toggle_adb_wireless' "$PLUGIN" && { echo "OK: toggle_adb_wireless presente"; PASS=$((PASS+1)); } || { echo "FALHA: toggle_adb_wireless ausente"; FAIL=$((FAIL+1)); }

echo "--- teste: NAO contem adb tcpip ---"
if grep -Eq 'adb tcpip|tcpip ' "$PLUGIN"; then
    echo "FALHA: contem adb tcpip (proibido)"; FAIL=$((FAIL+1))
else
    echo "OK: sem adb tcpip"; PASS=$((PASS+1)); fi

echo "--- teste: CONNECT_HOST e' 127.0.0.1 e todo adb connect usa $CONNECT_HOST ---"
grep -q 'CONNECT_HOST="127.0.0.1"' "$PLUGIN" || { echo "FALHA: CONNECT_HOST nao e 127.0.0.1"; FAIL=$((FAIL+1)); }
if grep -Eq 'adb connect [^"$]' "$PLUGIN"; then
    echo "FALHA: ha adb connect com host literal nao-variavel"; FAIL=$((FAIL+1))
else
    echo "OK: adb connect sempre usa variavel"; PASS=$((PASS+1)); fi

if [ $FAIL -eq 0 ]; then echo "RESULTADO: TESTES adb-connect-static PASSARAM"; else echo "RESULTADO: $FAIL FALHA(S)"; fi
exit $FAIL
