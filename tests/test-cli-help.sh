#!/usr/bin/env bash
# Teste: shizuku help lista os verbos obrigatórios.
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SHIZUKU="$SCRIPT_DIR/../src/bin/shizuku"

PASS=0; FAIL=0

[ -x "$SHIZUKU" ] || chmod +x "$SHIZUKU"

echo "--- teste: help lista verbos ---"
out="$(bash "$SHIZUKU" help 2>&1 || true)"

for v in install doctor rish info open stop exec shell version uninstall sui wireless usb-loopback keepalive pm-install start-daemon adb-connect wait aliases help; do
    if echo "$out" | grep -q "$v"; then
        echo "OK: verbo '$v' listado"
    else
        echo "FALHA: verbo '$v' NÃO listado"; FAIL=$((FAIL+1))
    fi
done

echo "--- teste: install menciona --source latest ---"
if echo "$out" | grep -q -- '--source latest'; then
    echo "OK: --source latest mencionado no help"
else
    echo "FALHA: --source latest não mencionado"; FAIL=$((FAIL+1))
fi

echo "--- teste: help retorna 0 ou lista sem erro ---"
if echo "$out" | grep -qi "erro\|not found"; then
    echo "FALHA: help deu erro"; FAIL=$((FAIL+1))
else
    echo "OK: help sem erro"
fi

echo "--- teste: doctor no host não recursiona (timeout 2s) ---"
out_doc="$(timeout 2 bash "$SHIZUKU" doctor 2>&1 || true)"
rc_doc=$?
if echo "$out_doc" | grep -qi "recurs\|infinito\|loop"; then
    echo "FALHA: doctor suspeito de recursão"; FAIL=$((FAIL+1))
elif [ $rc_doc -eq 124 ]; then
    echo "FALHA: doctor excedeu timeout 2s (possível loop)"; FAIL=$((FAIL+1))
else
    echo "OK: doctor terminou sem recursão (rc=$rc_doc)"
fi

echo "--- teste: shebang não é #!/usr/bin/env (Android não tem /usr/bin/env) ---"
for f in "$SHIZUKU" "$SCRIPT_DIR/../src/bin/shk"; do
    first="$(head -1 "$f")"
    if [ "$first" = "#!/usr/bin/env bash" ]; then
        echo "FALHA: $f ainda usa #!/usr/bin/env bash"; FAIL=$((FAIL+1))
    else
        echo "OK: $f shebang=$first"
    fi
done

if [ $FAIL -eq 0 ]; then echo "RESULTADO: TESTES cli-help PASSARAM"; else echo "RESULTADO: $FAIL FALHA(S)"; fi
exit $FAIL
