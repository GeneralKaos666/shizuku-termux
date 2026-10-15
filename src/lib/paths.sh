#!/usr/bin/env bash
# paths.sh — caminhos e helpers do núcleo shizuku-termux
# Sourceável. Não executa sozinho.
set -u

st_prefix() { echo "${PREFIX:-${HOME:-/tmp}/.shizuku-termux-prefix}"; }

st_prefix_lib() { echo "$(st_prefix)/lib/shizuku-termux"; }

st_rish_path()     { echo "$(st_prefix_lib)/rish"; }
st_dex_path()      { echo "$(st_prefix_lib)/rish_shizuku.dex"; }
st_lib_path()      { echo "$(st_prefix_lib)/librish.so"; }
st_bin_rish_path() { echo "$(st_prefix)/bin/rish"; }

st_app_id() {
    if [ -n "${TERMUX_APP__PACKAGE_NAME:-}" ]; then
        echo "$TERMUX_APP__PACKAGE_NAME"
    else
        echo "com.termux"
    fi
}

st_arch_to_abi() {
    local arch
    arch="$(uname -m 2>/dev/null || echo unknown)"
    case "$arch" in
        aarch64) echo "arm64-v8a" ;;
        armv7l|armv8l) echo "armeabi-v7a" ;;
        x86_64) echo "x86_64" ;;
        i686) echo "x86" ;;
        *) echo "" ;;
    esac
}

st_pm_path() {
    command -v pm >/dev/null 2>&1 && echo pm || echo /system/bin/pm
}

st_apk_path_via_pm() {
    "$(st_pm_path)" path moe.shizuku.privileged.api 2>/dev/null | sed 's/^package://' || true
}

# Resolve o binário adb a usar.
# Ordem: ST_ADB (override de teste) -> ~/.local/bin/adb (front-end unificado)
#        -> command -v adb (PATH) -> $PREFIX/bin/termux-adb (OTG patchado) -> falha.
st_adb_bin() {
    if [ -n "${ST_ADB:-}" ] && [ -x "${ST_ADB}" ]; then
        echo "${ST_ADB}"
        return 0
    fi
    if [ -x "${HOME:-}/.local/bin/adb" ]; then
        echo "${HOME:-}/.local/bin/adb"
        return 0
    fi
    local p
    p="$(command -v adb 2>/dev/null || true)"
    if [ -n "${p}" ]; then
        echo "${p}"
        return 0
    fi
    if [ -x "${PREFIX:-}/bin/termux-adb" ]; then
        echo "${PREFIX:-}/bin/termux-adb"
        return 0
    fi
    echo "ERRO: adb ausente. Instale termux-adb: https://github.com/rianprei/termux-adb" >&2
    return 1
}

# Chama o binário adb resolvido com "$@".
st_adb() {
    local bin
    bin="$(st_adb_bin)" || return $?
    "${bin}" "$@"
}
