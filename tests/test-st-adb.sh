#!/usr/bin/env bash
# Teste: st_adb_bin / st_adb com e sem ST_ADB, sem rede real.
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
. "$SCRIPT_DIR/../src/lib/paths.sh"

# O source acima herda 'set -euo pipefail' de extract-apk.sh; desligamos para gerenciar PASS/FAIL manualmente.
set +e
set +u

PASS=0; FAIL=0

echo "--- teste 1: ST_ADB apontando para stub inexistente → st_adb_bin falha ---"
tmpbin0="$(mktemp -d)"
ST_ADB="/tmp/nao-existe-adb" PATH="$tmpbin0" st_adb_bin >/tmp/stadb1.out 2>&1 || rc=$?
rc=${rc:-0}
[ "$rc" = "1" ] && { echo "OK: st_adb_bin retorna 1 sem ST_ADB válido"; PASS=$((PASS+1)); } || { echo "FALHA: esperado 1, obteve ${rc:-}"; FAIL=$((FAIL+1)); }
rm -rf "$tmpbin0"

echo "--- teste 2: ST_ADB apontando para stub executável → st_adb usa esse path ---"
tmpbin="$(mktemp -d)"
cat > "$tmpbin/adb-stub" <<'ADB'
#!/bin/bash
echo "stub-adb: $*"
ADB
chmod 755 "$tmpbin/adb-stub"
out="$(ST_ADB="$tmpbin/adb-stub" st_adb version 2>&1)" || rc=$?
echo "$out" | grep -q "stub-adb: version" && { echo "OK: st_adb usa ST_ADB ($out)"; PASS=$((PASS+1)); } || { echo "FALHA: saida=$out rc=$rc"; FAIL=$((FAIL+1)); }
rm -rf "$tmpbin"

echo "--- teste 3: Sem ST_ADB e sem adb no PATH → mensagem contém github.com/rianprei/termux-adb ---"
# Criar um PATH vazio/sem adb
tmpbin2="$(mktemp -d)"
out="$(PATH="$tmpbin2" st_adb_bin 2>&1)" || rc=$?
echo "$out" | grep -q "github.com/rianprei/termux-adb" && { echo "OK: mensagem menciona github.com/rianprei/termux-adb"; PASS=$((PASS+1)); } || { echo "FALHA: saida=$out rc=$rc"; FAIL=$((FAIL+1)); }
rm -rf "$tmpbin2"

if [ $FAIL -eq 0 ]; then echo "RESULTADO: TESTES st-adb PASSARAM"; else echo "RESULTADO: $FAIL FALHA(S)"; fi
exit $FAIL
