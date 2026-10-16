#!/usr/bin/env bash
# plugin keepalive — jecis heartbeat.
# Background loop: checks rish -c id; on failure, reruns start.sh via start-daemon.
# Does not fake "keepalive active" without checking.

ST_KEEPALIVE_INTERVAL="${ST_KEEPALIVE_INTERVAL:-30}"
ST_KEEPALIVE_PIDFILE="${ST_KEEPALIVE_PIDFILE:-${PREFIX:-/tmp}/var/run/shizuku-keepalive.pid}"

st_plugin_keepalive_start() {
    local interval="${1:-$ST_KEEPALIVE_INTERVAL}"
    if [ -f "$ST_KEEPALIVE_PIDFILE" ] && kill -0 "$(cat "$ST_KEEPALIVE_PIDFILE")" 2>/dev/null; then
        echo "keepalive already running (PID $(cat "$ST_KEEPALIVE_PIDFILE"))"
        return 0
    fi
    (
        while true; do
            if ! rish -c id >/dev/null 2>&1; then
                echo "[keepalive] rish did not respond, trying start-daemon..." >&2
                shizuku start-daemon >/dev/null 2>&1 || true
            fi
            sleep "$interval"
        done
    ) &
    echo $! > "$ST_KEEPALIVE_PIDFILE"
    echo "keepalive started (PID $(cat "$ST_KEEPALIVE_PIDFILE"), interval ${interval}s)"
    return 0
}

st_plugin_keepalive_stop() {
    if [ -f "$ST_KEEPALIVE_PIDFILE" ]; then
        kill "$(cat "$ST_KEEPALIVE_PIDFILE")" 2>/dev/null || true
        rm -f "$ST_KEEPALIVE_PIDFILE"
        echo "keepalive stopped"
    else
        echo "keepalive is not running"
    fi
    return 0
}

st_plugin_keepalive_status() {
    if [ -f "$ST_KEEPALIVE_PIDFILE" ] && kill -0 "$(cat "$ST_KEEPALIVE_PIDFILE")" 2>/dev/null; then
        echo "keepalive active (PID $(cat "$ST_KEEPALIVE_PIDFILE"))"
        return 0
    else
        echo "keepalive stopped"
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
