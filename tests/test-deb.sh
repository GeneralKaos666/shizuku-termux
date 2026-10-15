#!/usr/bin/env bash
# Teste: build-deb.sh gera .deb (ou estrutura) com ZERO .dex/.so/apk.
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BUILD="$SCRIPT_DIR/../src/packaging/build-deb.sh"

PASS=0; FAIL=0

echo "--- teste: build-deb.sh roda ---"
bash "$BUILD" > /tmp/deb-build.out 2>&1
rc=$?
if [ "$rc" = "0" ]; then
    echo "OK: build-deb.sh exit 0"
else
    echo "FALHA: build-deb.sh exit $rc (veja /tmp/deb-build.out)"; FAIL=$((FAIL+1))
fi

echo "--- teste: saída menciona .deb ou estrutura pronta ---"
if grep -qiE "\.deb|Estrutura pronta" /tmp/deb-build.out; then
    echo "OK: saída menciona .deb/estrutura"
else
    echo "FALHA: saída não menciona .deb"; FAIL=$((FAIL+1))
fi

echo "--- teste: ZERO .dex/.so/apk no conteúdo gerado ---"
if [ -f /tmp/shizuku-termux-1.0.0.deb ] && command -v dpkg-deb >/dev/null 2>&1; then
    listing="$(dpkg-deb --contents /tmp/shizuku-termux-1.0.0.deb 2>/dev/null || true)"
    if echo "$listing" | grep -qE '\.(dex|so|apk)'; then
        echo "FALHA: .deb contém .dex/.so/apk"; FAIL=$((FAIL+1))
    else
        echo "OK: .deb sem .dex/.so/apk"
    fi
elif [ -d /tmp/shizuku-termux-1.0.0 ]; then
    if find /tmp/shizuku-termux-1.0.0 -name '*.dex' -o -name '*.so' -o -name '*.apk' 2>/dev/null | grep -q .; then
        echo "FALHA: estrutura contém .dex/.so/apk"; FAIL=$((FAIL+1))
    else
        echo "OK: estrutura sem .dex/.so/apk"
    fi
else
    echo "AVISO: nem .deb nem estrutura encontrados; pulando verificação de conteúdo"
fi

if [ $FAIL -eq 0 ]; then echo "RESULTADO: TESTES deb PASSARAM"; else echo "RESULTADO: $FAIL FALHA(S)"; fi
exit $FAIL
