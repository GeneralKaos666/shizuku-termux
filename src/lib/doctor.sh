#!/usr/bin/env bash
# doctor.sh — health checklist of the shizuku-termux core
# Source paths.sh before using.
set -uo pipefail

st_doctor() {
    local rc=0 dex rish aid uid

    echo "=== shizuku-termux doctor ==="

    # 1. Termux environment
    if [ -z "${PREFIX:-}" ]; then
        echo "FAIL: PREFIX not set" >&2
        return 1
    fi
    echo "OK: PREFIX=$PREFIX"

    # 2. Shizuku APK installed?
    local apk
    apk="$("$(st_pm_path)" path moe.shizuku.privileged.api 2>/dev/null | sed 's/^package://' || true)"
    if [ -z "$apk" ]; then
        echo "FAIL: APK moe.shizuku.privileged.api not found (exit 4)" >&2
        return 4
    fi
    echo "OK: Shizuku APK: $apk"

    # 3. DEX exists?
    dex="$(st_dex_path)"
    if [ ! -f "$dex" ]; then
        echo "FAIL: DEX missing: $dex (exit 6)" >&2
        return 6
    fi
    echo "OK: DEX exists: $dex"

    # 4. DEX non-writable
    if [ -w "$dex" ]; then
        echo "FAIL: DEX writable — app_process aborts on A14 (exit 3)" >&2
        return 3
    fi
    echo "OK: DEX non-writable"

    # 5. Launcher exists?
    rish="$(st_rish_path)"
    if [ ! -f "$rish" ]; then
        echo "FAIL: launcher missing: $rish (exit 6)" >&2
        return 6
    fi
    echo "OK: launcher exists: $rish"

    # 6. RISH_APPLICATION_ID
    aid="$(st_app_id)"
    echo "INFO: RISH_APPLICATION_ID=$aid"

    # 6b. Resolved adb (informational, does not fail rc if missing)
    info_adb="$(st_adb_bin 2>/dev/null || true)"
    if [ -x "${HOME:-}/.local/bin/adb" ]; then
        info_tadb="yes (${HOME:-}/.local/bin/adb)"
    elif [ -x "${PREFIX:-}/bin/termux-adb" ]; then
        info_tadb="yes (${PREFIX:-}/bin/termux-adb)"
    elif command -v adb >/dev/null 2>&1; then
        info_tadb="yes ($(command -v adb))"
    else
        info_tadb="no"
    fi
    echo "INFO: adb=${info_adb:-missing}"
    echo "INFO: termux-adb=$info_tadb"

    # 7. Shizuku up? (device)
    if command -v rish >/dev/null 2>&1; then
        uid="$(rish -c id 2>/dev/null || true)"
        case "$uid" in
            *2000*) echo "OK: rish -c id → uid 2000 (ADB)" ;;
            *0*)    echo "OK: rish -c id → uid 0 (root/Sui)" ;;
            "")     echo "FAIL: Shizuku down (exit 2)" >&2; rc=2 ;;
            *)      echo "FAIL: unexpected uid '$uid' (exit 5)" >&2; rc=5 ;;
        esac
    else
        echo "INFO: rish not in PATH (host) — skipping device check"
    fi

    return $rc
}

# Waits for Shizuku to respond via rish -c true.
# Loops with a 2s interval. Timeout 0 = single attempt.
# Does not call start-daemon (keepalive handles the restart).
st_wait() {
    local timeout="${1:-${ST_WAIT_TIMEOUT:-60}}"
    local elapsed=0

    case "$timeout" in
        ''|*[!0-9]*) echo "ERROR: invalid timeout: $timeout" >&2; return 1 ;;
    esac

    while true; do
        if rish -c true >/dev/null 2>&1; then
            echo "OK: Shizuku responded (rish -c true)"
            return 0
        fi
        [ "$timeout" -eq 0 ] && break
        [ "$elapsed" -ge "$timeout" ] && break
        sleep 2
        elapsed=$((elapsed + 2))
    done

    echo "ERROR: Shizuku did not respond after ${timeout}s (exit 2)" >&2
    return 2
}
