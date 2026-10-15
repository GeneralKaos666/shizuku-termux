#!/usr/bin/env bash
# doctor.sh — checklist de saúde do núcleo shizuku-termux
# Source paths.sh antes de usar.
set -uo pipefail

st_doctor() {
    local rc=0 dex rish aid uid

    echo "=== doctor shizuku-termux ==="

    # 1. Ambiente Termux
    if [ -z "${PREFIX:-}" ]; then
        echo "FALHA: PREFIX não definido" >&2
        return 1
    fi
    echo "OK: PREFIX=$PREFIX"

    # 2. APK Shizuku instalado?
    local apk
    apk="$("$(st_pm_path)" path moe.shizuku.privileged.api 2>/dev/null | sed 's/^package://' || true)"
    if [ -z "$apk" ]; then
        echo "FALHA: APK moe.shizuku.privileged.api não encontrado (exit 4)" >&2
        return 4
    fi
    echo "OK: APK Shizuku: $apk"

    # 3. DEX existe?
    dex="$(st_dex_path)"
    if [ ! -f "$dex" ]; then
        echo "FALHA: DEX ausente: $dex (exit 6)" >&2
        return 6
    fi
    echo "OK: DEX existe: $dex"

    # 4. DEX non-writable
    if [ -w "$dex" ]; then
        echo "FALHA: DEX gravável — app_process aborta no A14 (exit 3)" >&2
        return 3
    fi
    echo "OK: DEX non-writable"

    # 5. Launcher existe?
    rish="$(st_rish_path)"
    if [ ! -f "$rish" ]; then
        echo "FALHA: launcher ausente: $rish (exit 6)" >&2
        return 6
    fi
    echo "OK: launcher existe: $rish"

    # 6. RISH_APPLICATION_ID
    aid="$(st_app_id)"
    echo "INFO: RISH_APPLICATION_ID=$aid"

    # 6b. Adb resolvido (informativo, não derruba rc se faltar)
    info_adb="$(st_adb_bin 2>/dev/null || true)"
    if [ -x "${HOME:-}/.local/bin/adb" ]; then
        info_tadb="sim (${HOME:-}/.local/bin/adb)"
    elif [ -x "${PREFIX:-}/bin/termux-adb" ]; then
        info_tadb="sim (${PREFIX:-}/bin/termux-adb)"
    elif command -v adb >/dev/null 2>&1; then
        info_tadb="sim ($(command -v adb))"
    else
        info_tadb="não"
    fi
    echo "INFO: adb=${info_adb:-ausente}"
    echo "INFO: termux-adb=$info_tadb"

    # 7. Shizuku up? (device)
    if command -v rish >/dev/null 2>&1; then
        uid="$(rish -c id 2>/dev/null || true)"
        case "$uid" in
            *2000*) echo "OK: rish -c id → uid 2000 (ADB)" ;;
            *0*)    echo "OK: rish -c id → uid 0 (root/Sui)" ;;
            "")     echo "FALHA: Shizuku down (exit 2)" >&2; rc=2 ;;
            *)      echo "FALHA: uid inesperado '$uid' (exit 5)" >&2; rc=5 ;;
        esac
    else
        echo "INFO: rish não no PATH (host) — pulando checagem de device"
    fi

    return $rc
}

# Espera o Shizuku responder via rish -c true.
# Loop com intervalo 2s. Timeout 0 = uma tentativa.
# Nao chama start-daemon (o keepalive cuida do restart).
st_wait() {
    local timeout="${1:-${ST_WAIT_TIMEOUT:-60}}"
    local elapsed=0

    case "$timeout" in
        ''|*[!0-9]*) echo "ERRO: timeout invalido: $timeout" >&2; return 1 ;;
    esac

    while true; do
        if rish -c true >/dev/null 2>&1; then
            echo "OK: Shizuku respondeu (rish -c true)"
            return 0
        fi
        [ "$timeout" -eq 0 ] && break
        [ "$elapsed" -ge "$timeout" ] && break
        sleep 2
        elapsed=$((elapsed + 2))
    done

    echo "ERRO: Shizuku nao respondeu apos ${timeout}s (exit 2)" >&2
    return 2
}
