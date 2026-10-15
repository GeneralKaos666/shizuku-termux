#!/usr/bin/env bash
# plugin keepalive — heartbeat do jecis.
# Loop em background: verifica rish -c id; se falhar, reexecuta start.sh via start-daemon.
# Não finge "keepalive ativo" sem verificar.

ST_KEEPALIVE_INTERVAL="${ST_KEEPALIVE_INTERVAL:-30}"
ST_KEEPALIVE_PIDFILE="${ST_KEEPALIVE_PIDFILE:-${PREFIX:-/tmp}/var/run/shizuku-keepalive.pid}"

st_plugin_keepalive_start() {
    local interval="${1:-$ST_KEEPALIVE_INTERVAL}"
    if [ -f "$ST_KEEPALIVE_PIDFILE" ] && kill -0 "$(cat "$ST_KEEPALIVE_PIDFILE")" 2>/dev/null; then
        echo "keepalive já rodando (PID $(cat "$ST_KEEPALIVE_PIDFILE"))"
        return 0
    fi
    (
        while true; do
            if ! rish -c id >/dev/null 2>&1; then
                echo "[keepalive] rish não respondeu, tentando start-daemon..." >&2
                shizuku start-daemon >/dev/null 2>&1 || true
            fi
            sleep "$interval"
        done
    ) &
    echo $! > "$ST_KEEPALIVE_PIDFILE"
    echo "keepalive iniciado (PID $(cat "$ST_KEEPALIVE_PIDFILE"), intervalo ${interval}s)"
    return 0
}

st_plugin_keepalive_stop() {
    if [ -f "$ST_KEEPALIVE_PIDFILE" ]; then
        kill "$(cat "$ST_KEEPALIVE_PIDFILE")" 2>/dev/null || true
        rm -f "$ST_KEEPALIVE_PIDFILE"
        echo "keepalive parado"
    else
        echo "keepalive não está rodando"
    fi
    return 0
}

st_plugin_keepalive_status() {
    if [ -f "$ST_KEEPALIVE_PIDFILE" ] && kill -0 "$(cat "$ST_KEEPALIVE_PIDFILE")" 2>/dev/null; then
        echo "keepalive ativo (PID $(cat "$ST_KEEPALIVE_PIDFILE"))"
        return 0
    else
        echo "keepalive parado"
        return 3
    fi
}

st_plugin_keepalive() {
    local action="${1:-status}"
    case "$action" in
        start)  st_plugin_keepalive_start "${2:-$ST_KEEPALIVE_INTERVAL}" ;;
        stop)   st_plugin_keepalive_stop ;;
        status|*) st_plugin_keepalive_status ;;
    esac
}
