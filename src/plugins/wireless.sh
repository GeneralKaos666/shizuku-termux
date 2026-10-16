#!/usr/bin/env bash
# plugin wireless — adb pair/connect IP:port + code (NOT 127.0.0.1).

st_plugin_wireless() {
    local target="" code=""
    while [ $# -gt 0 ]; do
        case "$1" in
            --target) target="${2:-}"; shift 2 ;;
            --target=*) target="${1#--target=}"; shift ;;
            --code) code="${2:-}"; shift 2 ;;
            --code=*) code="${1#*=}"; shift ;;
            *) shift ;;
        esac
    done

    case "$target" in
        ""|127.0.0.1|localhost) echo "ERROR: wireless does not use 127.0.0.1 (use a real IP:port)" >&2; return 1 ;;
    esac

    echo "Pairing wireless: $target"
    if [ -n "$code" ]; then
        st_adb pair "$target" "$code" || return $?
    fi
    st_adb connect "$target" || return $?
    echo "OK: connected via wireless at $target"
    return 0
}
