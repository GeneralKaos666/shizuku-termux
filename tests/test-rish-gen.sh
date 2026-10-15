#!/usr/bin/env bash
# Teste: rish gerado de rish.in não tem PKG, tem ShizukuShellLoader e check de DEX gravável→exit 3.
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SRC="$SCRIPT_DIR/../src/bin/rish.in"
GEN="/tmp/rish_generated.sh"
export PREFIX="${PREFIX:-/data/data/com.termux/files/usr}"

PASS=0; FAIL=0

[ -f "$SRC" ] || { echo "FALHA: rish.in não encontrado"; exit 1; }

# Gera substitui placeholders
sed -e 's/@APP_ID@/com.termux/g' \
    -e "s|@DEX@|$PREFIX/lib/shizuku-termux/rish_shizuku.dex|g" \
    -e 's|@LIB@||g' \
    -e 's|@LOADER@|rikka.shizuku.shell.ShizukuShellLoader|g' \
    "$SRC" > "$GEN"

echo "--- teste: placeholder @APP_ID@ substituído (não fica PKG) ---"
if grep -q '@APP_ID@' "$GEN"; then
    echo "FALHA: placeholder @APP_ID@ não substituído"; FAIL=$((FAIL+1))
elif grep -q 'APP_ID="PKG"' "$GEN"; then
    echo "FALHA: APP_ID ficou como PKG literal"; FAIL=$((FAIL+1))
else
    echo "OK: APP_ID resolvido (sem PKG placeholder)"
fi

echo "--- teste: contém com.termux como app id ---"
if grep -q 'com.termux' "$GEN"; then
    echo "OK: contém com.termux"
else
    echo "FALHA: sem com.termux"; FAIL=$((FAIL+1))
fi

echo "--- teste: contém classe FQCN rikka.shizuku.shell.ShizukuShellLoader ---"
if grep -Fq 'rikka.shizuku.shell.ShizukuShellLoader' "$GEN"; then
    echo "OK: classe FQCN Rikka presente"
else
    echo "FALHA: sem rikka.shizuku.shell.ShizukuShellLoader"; FAIL=$((FAIL+1))
fi

echo "--- teste: recusa libsu (topjohnwu) ---"
if grep -Fq 'com.topjohnwu' "$GEN"; then
    echo "FALHA: contém classe libsu (topjohnwu)"; FAIL=$((FAIL+1))
else
    echo "OK: sem libsu (topjohnwu)"
fi

echo "--- teste: contém -Djava.class.path= (DEX injetado) ---"
if grep -F -- '-Djava.class.path=' "$GEN"; then
    echo "OK: contém -Djava.class.path="
else
    echo "FALHA: sem -Djava.class.path="; FAIL=$((FAIL+1))
fi

echo "--- teste: contém app_process /system/bin ---"
if grep -q '/system/bin/app_process' "$GEN"; then
    echo "OK: contém app_process /system/bin"
else
    echo "FALHA: sem app_process /system/bin"; FAIL=$((FAIL+1))
fi

echo "--- teste: contém check de DEX gravável → exit 3 ---"
if grep -q 'exit 3' "$GEN"; then
    echo "OK: contém exit 3"
else
    echo "FALHA: sem exit 3"; FAIL=$((FAIL+1))
fi

if [ $FAIL -eq 0 ]; then echo "RESULTADO: TESTES rish-gen PASSARAM"; else echo "RESULTADO: $FAIL FALHA(S)"; fi
exit $FAIL
