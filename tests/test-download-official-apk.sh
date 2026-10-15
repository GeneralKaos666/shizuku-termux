#!/usr/bin/env bash
# Teste: st_apk_url_from_release_json com JSON fixture (sem rede real).
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
. "$SCRIPT_DIR/../src/lib/paths.sh"
. "$SCRIPT_DIR/../src/lib/extract-apk.sh"

# O source acima herda 'set -e' de extract-apk.sh; desabilitamos pois gerenciamos PASS/FAIL manualmente.
set +e

PASS=0; FAIL=0

# ── Teste 1: JSON fixture com asset .apk válido ──
JSON1="$(mktemp)"
cat > "$JSON1" <<'JSON'
{
  "tag_name": "v13.6.0",
  "assets": [
    {"name": "Shizuku.apk", "browser_download_url": "https://github.com/RikkaApps/Shizuku/releases/download/v13.6.0/Shizuku.apk"},
    {"name": "rish", "browser_download_url": "https://github.com/RikkaApps/Shizuku/releases/download/v13.6.0/rish"}
  ]
}
JSON

url="$(st_apk_url_from_release_json "$JSON1")"
[ "$url" = "https://github.com/RikkaApps/Shizuku/releases/download/v13.6.0/Shizuku.apk" ] && {
    echo "OK: extraiu URL .apk do JSON"; PASS=$((PASS+1))
} || { echo "FALHA: URL extraída incorreta: $url"; FAIL=$((FAIL+1)); }

# ── Teste 2: JSON sem asset .apk (apenas 'rish' fake) ──
JSON2="$(mktemp)"
cat > "$JSON2" <<'JSON'
{
  "tag_name": "v13.6.0",
  "assets": [
    {"name": "rish", "browser_download_url": "https://github.com/RikkaApps/Shizuku/releases/download/v13.6.0/rish"}
  ]
}
JSON

url2="$(st_apk_url_from_release_json "$JSON2")"
[ -z "$url2" ] && {
    echo "OK: rejeitou JSON sem asset .apk"; PASS=$((PASS+1))
} || { echo "FALHA: não deveria extrair .apk de JSON sem asset"; FAIL=$((FAIL+1)); }

# ── Teste 3: função existe ──
command -v st_apk_url_from_release_json >/dev/null 2>&1 && {
    echo "OK: função st_apk_url_from_release_json existe"; PASS=$((PASS+1))
} || { echo "FALHA: função não encontrada"; FAIL=$((FAIL+1)); }

command -v st_download_official_apk >/dev/null 2>&1 && {
    echo "OK: função st_download_official_apk existe"; PASS=$((PASS+1))
} || { echo "FALHA: função não encontrada"; FAIL=$((FAIL+1)); }

# ── Teste 4: --source lê o próximo argumento e compara com 'latest' ──
SHIZUKU_SRC="$SCRIPT_DIR/../src/bin/shizuku"
grep -q -- '--source)' "$SHIZUKU_SRC" && {
    echo "OK: case --source presente no CLI"; PASS=$((PASS+1))
} || { echo "FALHA: case --source ausente"; FAIL=$((FAIL+1)); }

# O case --source deve fazer shift e comparar $1 com 'latest' (não source_latest=1 sem ler argumento)
if grep -A3 -- '--source)' "$SHIZUKU_SRC" | grep -q 'shift' && grep -A3 -- '--source)' "$SHIZUKU_SRC" | grep -q 'case "\$1"'; then
    echo "OK: --source lê o próximo argumento após shift"; PASS=$((PASS+1))
else
    echo "FALHA: --source não lê próximo argumento"; FAIL=$((FAIL+1)); fi

# Rejeita 'source_latest=1; shift' sem ler argumento (padrão antigo quebrado)
if grep -A1 -- '--source)' "$SHIZUKU_SRC" | grep -q 'source_latest=1'; then
    echo "FALHA: --source ainda faz source_latest=1 sem ler argumento"; FAIL=$((FAIL+1))
else
    echo "OK: --source não define source_latest sem ler argumento"; PASS=$((PASS+1)); fi

rm -f "$JSON1" "$JSON2"

if [ $FAIL -eq 0 ]; then echo "RESULTADO: TESTES download-official-apk PASSARAM"; else echo "RESULTADO: $FAIL FALHA(S)"; fi
exit $FAIL
