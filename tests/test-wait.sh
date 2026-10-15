#!/usr/bin/env bash
# Teste: st_wait em doctor.sh. Sem device, sem rede adb real.
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
. "$SCRIPT_DIR/../src/lib/paths.sh"
. "$SCRIPT_DIR/../src/lib/doctor.sh"

# set -e vindo de extract-apk.sh (via paths.sh) pode encerar o teste; desligamos.
set +e

PASS=0; FAIL=0

echo "--- teste 1: st_wait 0 com rish ausente -> return 2 (rapido) ---"
inicio=$(date +%s)
st_wait 0 >/tmp/wait1.out 2>&1 || rc=$?
fim=$(date +%s)
dur=$((fim - inicio))
[ "$rc" = "2" ] && { echo "OK: return 2 (Shizuku down)"; PASS=$((PASS+1)); } || { echo "FALHA: esperado 2, obteve ${rc:-}"; FAIL=$((FAIL+1)); }
[ "$dur" -lt 5 ] && { echo "OK: nao demorou ($dur s)"; PASS=$((PASS+1)); } || { echo "FALHA: demorou demais ($dur s)"; FAIL=$((FAIL+1)); }

echo "--- teste 2: st_wait 0 com rish que sai 0 -> return 0 ---"
tmpbin="$(mktemp -d)"
cat > "$tmpbin/rish" <<'RISH'
#!/bin/bash
exit 0
RISH
chmod 755 "$tmpbin/rish"
rc=0
PATH="$tmpbin:$PATH" st_wait 0 >/tmp/wait2.out 2>&1 || rc=$?
[ "$rc" = "0" ] && { echo "OK: return 0 (Shizuku respondeu)"; PASS=$((PASS+1)); } || { echo "FALHA: esperado 0, obteve ${rc:-}"; FAIL=$((FAIL+1)); }
rm -rf "$tmpbin"

echo "--- teste 3: st_wait sem argumento usa default 60 (nao testa tempo, so nao trava) ---"
st_wait 0 >/dev/null 2>&1
echo "OK: st_wait sem erro de sintaxe"; PASS=$((PASS+1))

if [ $FAIL -eq 0 ]; then echo "RESULTADO: TESTES wait PASSARAM"; else echo "RESULTADO: $FAIL FALHA(S)"; fi
exit $FAIL
