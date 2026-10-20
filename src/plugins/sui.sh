#!/usr/bin/env bash
# plugin sui — shizuku|sui backend switch (reimplemented; default shizuku).
# Writes the choice to $ST_ROOT/backend; the rish.in generate reads this file.
# Does not copy the GPL file from rish4termux.

st_plugin_sui() {
    local backend=""
    while [ $# -gt 0 ]; do
        case "$1" in
            --backend) backend="${2:-}"; shift 2 ;;
            --backend=*) backend="${1#--backend=}"; shift ;;
            *) shift ;;
        esac
    done

    local backend_file="${ST_ROOT:-}/backend"

    case "$backend" in
        sui)
            echo "sui" > "$backend_file"
            echo "Backend: sui → DEX rish_sui.dex + loader rikka.sui.shell.Shell (reimplemented, no GPL)"
            ;;
        shizuku|"")
            echo "shizuku" > "$backend_file"
            echo "Backend: shizuku (default) → loader rikka.shizuku.shell.ShizukuShellLoader"
            ;;
        *)
            echo "ERROR: unknown backend: $backend" >&2
            return 1
            ;;
    esac
    return 0
}

st_plugin_sui_current() {
    [ -f "${ST_ROOT:-}/backend" ] && cat "${ST_ROOT:-}/backend" || echo "shizuku"
}
