#!/usr/bin/env bash
# Teste estático: plugin start-daemon contém start.sh oficial, libshizuku.so e --apk=.
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PLUGIN="$SCRIPT_DIR/../src/plugins/start-daemon.sh"

PASS=0; FAIL=0

[ -f "$PLUGIN" ] || { echo "FALHA: plugin não encontrado"; exit 1; }

echo "--- teste: contém start.sh oficial ---"
grep -q 'start.sh' "$PLUGIN" && { echo "OK: start.sh presente"; PASS=$((PASS+1)); } || { echo "FALHA: start.sh ausente"; FAIL=$((FAIL+1)); }

echo "--- teste: contém pm path para achar APK ---"
grep -q 'pm path moe.shizuku.privileged.api' "$PLUGIN" && { echo "OK: pm path presente"; PASS=$((PASS+1)); } || { echo "FALHA: pm path ausente"; FAIL=$((FAIL+1)); }

echo "--- teste: contém libshizuku.so ---"
grep -q 'libshizuku.so' "$PLUGIN" && { echo "OK: libshizuku.so presente"; PASS=$((PASS+1)); } || { echo "FALHA: libshizuku.so ausente"; FAIL=$((FAIL+1)); }

echo "--- teste: contém --apk= ---"
grep -q -- '--apk=' "$PLUGIN" && { echo "OK: --apk= presente"; PASS=$((PASS+1)); } || { echo "FALHA: --apk= ausente"; FAIL=$((FAIL+1)); }

echo "--- teste: NÃO contém adb tcpip / adb pair / adb connect 127.0.0.1 ---"
if grep -qE 'adb (tcpip|pair|connect 127\.0\.0\.1)' "$PLUGIN"; then
    echo "FALHA: contém comandos de rede proibidos"; FAIL=$((FAIL+1))
else
    echo "OK: sem comandos de rede proibidos"; PASS=$((PASS+1)); fi

echo "--- teste: NÃO contém pm install / su / setenforce ---"
if grep -qE 'pm install|su |setenforce' "$PLUGIN"; then
    echo "FALHA: contém comandos proibidos"; FAIL=$((FAIL+1))
else
    echo "OK: sem comandos proibidos"; PASS=$((PASS+1)); fi

if [ $FAIL -eq 0 ]; then echo "RESULTADO: TESTES start-daemon-static PASSARAM"; else echo "RESULTADO: $FAIL FALHA(S)"; fi
exit $FAIL
