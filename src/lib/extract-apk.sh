#!/usr/bin/env bash
# extract-apk.sh — extracts rish + dex from the Shizuku APK (installed via pm or a local file).
# Source paths.sh before using.
set -euo pipefail

st_require_unzip() {
    command -v unzip >/dev/null 2>&1 || { echo "ERROR: unzip not found" >&2; return 4; }
}

# Extracts assets/rish and assets/rish_shizuku.dex from an APK (zip) into $dest.
# Modes: rish 755, dex 400. Refuses if any asset is missing. No network.
st_extract_from_apk() {
    local apk="$1" dest="$2"
    [ -f "$apk" ] || { echo "ERROR: APK not found: $apk" >&2; return 4; }
    st_require_unzip || return $?
    mkdir -p "$dest"

    local tmpdir="" found_rish found_dex abi
    tmpdir="$(mktemp -d)" || return 1

    unzip -o -q "$apk" 'assets/rish' -d "$tmpdir" 2>/dev/null || true
    found_rish="$(find "$tmpdir" -name rish -type f 2>/dev/null | head -1)"
    if [ -z "$found_rish" ]; then
        rm -rf "$tmpdir" 2>/dev/null || true
        echo "ERROR: APK has no assets/rish asset" >&2; return 4
    fi

    unzip -o -q "$apk" 'assets/rish_shizuku.dex' -d "$tmpdir" 2>/dev/null || true
    found_dex="$(find "$tmpdir" -name rish_shizuku.dex -type f 2>/dev/null | head -1)"
    if [ -z "$found_dex" ]; then
        rm -rf "$tmpdir" 2>/dev/null || true
        echo "ERROR: APK has no assets/rish_shizuku.dex asset" >&2; return 4
    fi

    # Sui backend DEX (optional; used if st_plugin_sui wrote backend=sui).
    unzip -o -q "$apk" 'assets/rish_sui.dex' -d "$tmpdir" 2>/dev/null || true
    found_sui_dex="$(find "$tmpdir" -name rish_sui.dex -type f 2>/dev/null | head -1 || true)"
    if [ -n "$found_sui_dex" ]; then
        rm -f "$dest/rish_sui.dex"
        install -m 400 "$found_sui_dex" "$dest/rish_sui.dex"
    fi

    # Unpack the native libs BEFORE searching for librish.so (otherwise the .so never shows up).
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
            echo "WARNING: lib/$abi/librish.so not found in APK (skipped)" >&2
        fi
    fi

    rm -rf "$tmpdir" 2>/dev/null || true
    return 0
}

# Extracts via `pm path moe.shizuku.privileged.api` (APK installed on the device).
st_extract_from_pm() {
    local apk dest="$1"
    apk="$(st_apk_path_via_pm)"
    [ -n "$apk" ] || { echo "ERROR: APK moe.shizuku.privileged.api not installed" >&2; return 4; }
    st_extract_from_apk "$apk" "$dest"
}

# Extracts the download URL of the .apk asset from a GitHub release JSON.
# Only accepts URLs ending in .apk. Prints the URL to stdout.
st_apk_url_from_release_json() {
    local json_file="$1"
    [ -f "$json_file" ] || { echo "ERROR: JSON not found: $json_file" >&2; return 4; }
    grep -o 'https://[^"]*\.apk' "$json_file" | head -1
}

# Downloads the latest official APK from RikkaApps/Shizuku via the GitHub API.
# Only accepts assets ending in .apk. Never downloads releases/latest/download/rish.
# Writes the APK to $1. Returns 4 on network failure or invalid URL.
st_download_official_apk() {
    local out_apk="$1"
    local api_url="https://api.github.com/repos/RikkaApps/Shizuku/releases/latest"
    local tmp_json tmp_apk download_url status

    command -v curl >/dev/null 2>&1 || { echo "ERROR: curl not found" >&2; return 4; }

    tmp_json="$(mktemp)" || return 1
    tmp_apk="$(mktemp)" || { rm -f "$tmp_json"; return 1; }
    trap 'rm -f "$tmp_json" "$tmp_apk"' RETURN

    status="$(curl --fail --silent --show-error --output "$tmp_json" --write-out "%{http_code}" "$api_url" 2>/dev/null)" || {
        echo "ERROR: network failure while querying the GitHub API" >&2
        return 4
    }
    [ "$status" = "200" ] || { echo "ERROR: GitHub API returned HTTP $status" >&2; return 4; }

    download_url="$(st_apk_url_from_release_json "$tmp_json")"
    [ -n "$download_url" ] || { echo "ERROR: no .apk asset found in the release" >&2; return 4; }

    curl --fail --silent --show-error --location --output "$tmp_apk" "$download_url" 2>/dev/null || {
        echo "ERROR: failed to download the official APK" >&2
        return 4
    }

    [ -s "$tmp_apk" ] || { echo "ERROR: downloaded APK is empty" >&2; return 4; }

    cp "$tmp_apk" "$out_apk"
    return 0
}
