#!/usr/bin/env bash
# extract-apk.sh — extrai rish + dex do APK Shizuku (instalado via pm ou arquivo local).
# Source paths.sh antes de usar.
set -euo pipefail

st_require_unzip() {
    command -v unzip >/dev/null 2>&1 || { echo "ERRO: unzip não encontrado" >&2; return 4; }
}

# Extrai assets/rish e assets/rish_shizuku.dex de um APK (zip) para $dest.
# Modos: rish 755, dex 400. Recusa se faltar algum asset. Sem rede.
st_extract_from_apk() {
    local apk="$1" dest="$2"
    [ -f "$apk" ] || { echo "ERRO: APK não encontrado: $apk" >&2; return 4; }
    st_require_unzip || return $?
    mkdir -p "$dest"

    local tmpdir="" found_rish found_dex abi
    tmpdir="$(mktemp -d)" || return 1

    unzip -o -q "$apk" 'assets/rish' -d "$tmpdir" 2>/dev/null || true
    found_rish="$(find "$tmpdir" -name rish -type f 2>/dev/null | head -1)"
    if [ -z "$found_rish" ]; then
        rm -rf "$tmpdir" 2>/dev/null || true
        echo "ERRO: APK sem asset assets/rish" >&2; return 4
    fi

    unzip -o -q "$apk" 'assets/rish_shizuku.dex' -d "$tmpdir" 2>/dev/null || true
    found_dex="$(find "$tmpdir" -name rish_shizuku.dex -type f 2>/dev/null | head -1)"
    if [ -z "$found_dex" ]; then
        rm -rf "$tmpdir" 2>/dev/null || true
        echo "ERRO: APK sem asset assets/rish_shizuku.dex" >&2; return 4
    fi

    # DEX do backend Sui (opcional; usado se st_plugin_sui gravou backend=sui).
    unzip -o -q "$apk" 'assets/rish_sui.dex' -d "$tmpdir" 2>/dev/null || true
    found_sui_dex="$(find "$tmpdir" -name rish_sui.dex -type f 2>/dev/null | head -1 || true)"
    if [ -n "$found_sui_dex" ]; then
        rm -f "$dest/rish_sui.dex"
        install -m 400 "$found_sui_dex" "$dest/rish_sui.dex"
    fi

    # Unpack das libs nativas ANTES de procurar librish.so (caso contrário o .so nunca aparece).
    unzip -o -q "$apk" 'lib/*/librish.so' -d "$tmpdir" 2>/dev/null || true

    install -m 755 "$found_rish" "$dest/rish"
    rm -f "$dest/rish_shizuku.dex"
    install -m 400 "$found_dex" "$dest/rish_shizuku.dex"

    abi="$(st_arch_to_abi 2>/dev/null || echo)"
    if [ -n "$abi" ]; then
        local found_so
        found_so="$(find "$tmpdir" -path "*/lib/$abi/librish.so" -type f 2>/dev/null | head -1 || true)"
        if [ -n "$found_so" ]; then
            install -m 755 "$found_so" "$dest/librish.so"
        else
            echo "AVISO: lib/$abi/librish.so não encontrado no APK (pulado)" >&2
        fi
    fi

    rm -rf "$tmpdir" 2>/dev/null || true
    return 0
}

# Extrai via `pm path moe.shizuku.privileged.api` (APK instalado no dispositivo).
st_extract_from_pm() {
    local apk dest="$1"
    apk="$(st_apk_path_via_pm)"
    [ -n "$apk" ] || { echo "ERRO: APK moe.shizuku.privileged.api não instalado" >&2; return 4; }
    st_extract_from_apk "$apk" "$dest"
}

# Extrai a URL de download do asset .apk de um JSON de release do GitHub.
# Só aceita URLs que terminam em .apk. Imprime a URL no stdout.
st_apk_url_from_release_json() {
    local json_file="$1"
    [ -f "$json_file" ] || { echo "ERRO: JSON não encontrado: $json_file" >&2; return 4; }
    grep -o 'https://[^"]*\.apk' "$json_file" | head -1
}

# Baixa o APK oficial mais recente do RikkaApps/Shizuku via GitHub API.
# Só aceita assets que terminam em .apk. Nunca baixa releases/latest/download/rish.
# Grava o APK em $1. Retorna 4 em falha de rede ou URL inválida.
st_download_official_apk() {
    local out_apk="$1"
    local api_url="https://api.github.com/repos/RikkaApps/Shizuku/releases/latest"
    local tmp_json tmp_apk download_url status

    command -v curl >/dev/null 2>&1 || { echo "ERRO: curl não encontrado" >&2; return 4; }

    tmp_json="$(mktemp)" || return 1
    tmp_apk="$(mktemp)" || { rm -f "$tmp_json"; return 1; }
    trap 'rm -f "$tmp_json" "$tmp_apk"' RETURN

    status="$(curl --fail --silent --show-error --output "$tmp_json" --write-out "%{http_code}" "$api_url" 2>/dev/null)" || {
        echo "ERRO: falha na rede ao consultar GitHub API" >&2
        return 4
    }
    [ "$status" = "200" ] || { echo "ERRO: GitHub API retornou HTTP $status" >&2; return 4; }

    download_url="$(st_apk_url_from_release_json "$tmp_json")"
    [ -n "$download_url" ] || { echo "ERRO: nenhum asset .apk encontrado no release" >&2; return 4; }

    curl --fail --silent --show-error --location --output "$tmp_apk" "$download_url" 2>/dev/null || {
        echo "ERRO: falha ao baixar APK oficial" >&2
        return 4
    }

    [ -s "$tmp_apk" ] || { echo "ERRO: APK baixado está vazio" >&2; return 4; }

    cp "$tmp_apk" "$out_apk"
    return 0
}
