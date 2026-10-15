#!/usr/bin/env bash
# plugin sui — switch de backend shizuku|sui (reimplementado; default shizuku).
# Grava a escolha em $ST_ROOT/backend; o generate do rish.in lê este arquivo.
# Não copia arquivo GPL do rish4termux.

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
            echo "Backend: sui → DEX rish_sui.dex + loader rikka.sui.shell.Shell (reimplementado, sem GPL)"
            ;;
        shizuku|"")
            echo "shizuku" > "$backend_file"
            echo "Backend: shizuku (padrão) → loader rikka.shizuku.shell.ShizukuShellLoader"
            ;;
        *)
            echo "ERRO: backend desconhecido: $backend" >&2
            return 1
            ;;
    esac
    return 0
}

st_plugin_sui_current() {
    [ -f "${ST_ROOT:-}/backend" ] && cat "${ST_ROOT:-}/backend" || echo "shizuku"
}
