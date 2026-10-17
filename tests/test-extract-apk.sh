#!/usr/bin/env bash
# Teste: st_extract_from_apk com fixture zip local (sem rede).
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TMP="${TMPDIR:-/tmp}"
. "$SCRIPT_DIR/../src/lib/paths.sh"
. "$SCRIPT_DIR/../src/lib/extract-apk.sh"

PASS=0; FAIL=0

# Cria fixture zip com assets/rish e assets/rish_shizuku.dex
FIXTURE="$TMP/shizuku_fixture.zip"
rm -f "$FIXTURE"
tmpd="$(mktemp -d)"
mkdir -p "$tmpd/assets"
echo '#!/system/bin/sh' > "$tmpd/assets/rish"
echo 'DEX_PLACEHOLDER' > "$tmpd/assets/rish_shizuku.dex"
# ABI x86_64 no host → sem lib no fixture → aviso só.
python3 -c "import zipfile,os; z=zipfile.ZipFile('$FIXTURE','w'); z.write('$tmpd/assets/rish','assets/rish'); z.write('$tmpd/assets/rish_shizuku.dex','assets/rish_shizuku.dex'); z.close()"

DEST="$(mktemp -d)"
trap 'rm -rf "$tmpd" "$DEST"' RETURN

echo "--- teste: extração com modos corretos ---"
if st_extract_from_apk "$FIXTURE" "$DEST"; then
    echo "OK: extração retornou 0"
else
    echo "FALHA: extração retornou !=0"; FAIL=$((FAIL+1))
fi

if [ -f "$DEST/rish" ] && [ -f "$DEST/rish_shizuku.dex" ]; then
    echo "OK: rish e dex presentes"
else
    echo "FALHA: arquivos ausentes"; FAIL=$((FAIL+1))
fi

# Verifica modos: rish 755, dex 400
rish_mode="$(stat -c '%a' "$DEST/rish" 2>/dev/null || stat -f '%Lp' "$DEST/rish")"
dex_mode="$(stat -c '%a' "$DEST/rish_shizuku.dex" 2>/dev/null || stat -f '%Lp' "$DEST/rish_shizuku.dex")"
[ "$rish_mode" = "755" ] || { echo "FALHA: modo rish=$rish_mode (esperado 755)"; FAIL=$((FAIL+1)); }
[ "$dex_mode" = "400" ] || { echo "FALHA: modo dex=$dex_mode (esperado 400)"; FAIL=$((FAIL+1)); }

echo "--- teste: recusa APK sem assets ---"
badzip="$TMP/bad.zip"
echo 'not an apk' > "$badzip"
if st_extract_from_apk "$badzip" "$DEST" 2>/dev/null; then
    echo "FALHA: deveria recusar APK inválido"; FAIL=$((FAIL+1))
else
    echo "OK: APK inválido recusado"
fi

echo "--- teste: recusa APK inexistente ---"
if st_extract_from_apk "$TMP/naoexiste.apk" "$DEST" 2>/dev/null; then
    echo "FALHA: deveria recusar APK ausente"; FAIL=$((FAIL+1))
else
    echo "OK: APK ausente recusado"
fi

if [ $FAIL -eq 0 ]; then echo "RESULTADO: TESTES extract-apk PASSARAM"; else echo "RESULTADO: $FAIL FALHA(S)"; fi
exit $FAIL
