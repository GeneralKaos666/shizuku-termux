#!/usr/bin/env bash
# plugin wireless — adb pair/connect IP:porta + código (NÃO 127.0.0.1).

st_plugin_wireless() {
    local target="" code=""
    while [ $# -gt 0 ]; do
        case "$1" in
            --target) target="${2:-}"; shift 2 ;;
            --target=*) target="${1#--target=}"; shift ;;
            --code|--codigo) code="${2:-}"; shift 2 ;;
            --code=*|--codigo=*) code="${1#*=}"; shift ;;
            *) shift ;;
        esac
    done

    case "$target" in
        ""|127.0.0.1|localhost) echo "ERRO: wireless não usa 127.0.0.1 (use IP:porta real)" >&2; return 1 ;;
    esac

    echo "Emparelhando wireless: $target"
    if [ -n "$code" ]; then
        adb pair "$target" "$code" || return $?
    fi
    adb connect "$target" || return $?
    echo "OK: conectado via wireless em $target"
    return 0
}
