#!/usr/bin/env bash
# plugin adb-connect — wireless debugging on 127.0.0.1, without tcpip.
# Companion of wireless.sh (which rejects 127.0.0.1 and focuses on LAN).
# Does not copy QuickShell scripts; reimplemented.

CONNECT_HOST="127.0.0.1"

st_plugin_adb_connect() {
    local mode="${1:-}"

    case "$mode" in
        pair)
            local port="$2" code="$3"
            [ -n "$port" ] && [ -n "$code" ] || { echo "ERROR: usage: adb-connect pair <port> <code>" >&2; return 1; }
            is_port "$port" || { echo "ERROR: invalid port: $port" >&2; return 1; }
            st_adb_bin >/dev/null 2>&1 || { echo "ERROR: adb not found" >&2; return 1; }
            echo "Pairing wireless: $CONNECT_HOST:$port"
            st_adb pair "$CONNECT_HOST:$port" "$code" || return $?
            echo "OK: paired at $CONNECT_HOST:$port"
            return 0
            ;;
        status)
            st_adb_bin >/dev/null 2>&1 || { echo "ERROR: adb not found" >&2; return 1; }
            echo "ADB devices:"
            st_adb devices
            return 0
            ;;
        disconnect)
            local port="${2:-5555}"
            is_port "$port" || { echo "ERROR: invalid port: $port" >&2; return 1; }
            st_adb_bin >/dev/null 2>&1 || { echo "ERROR: adb not found" >&2; return 1; }
            echo "Disconnecting: $CONNECT_HOST:$port"
            st_adb disconnect "$CONNECT_HOST:$port" || return $?
            echo "OK: disconnected"
            return 0
            ;;
        wf)
            echo "Opening wireless debugging settings via rish ..."
            if st_rish -c 'am start -a android.settings.APPLICATION_DEVELOPMENT_SETTINGS --es ":settings:fragment_args_key" toggle_adb_wireless' >/dev/null 2>&1; then
                echo "OK: wireless debugging page opened via rish"
                return 0
            fi
            if st_rish -c 'am start -a android.settings.DEVELOPMENT_SETTINGS' >/dev/null 2>&1; then
                echo "OK: developer options page opened via rish"
                return 0
            fi
            echo "ERROR: could not open developer options via rish" >&2
            return 1
            ;;
        ""|*)
            local port="$mode"
            [ -n "$port" ] || { echo "ERROR: usage: adb-connect <port> | pair <port> <code> | status | disconnect [port] | wf" >&2; return 1; }
            is_port "$port" || { echo "ERROR: invalid port: $port" >&2; return 1; }
            st_adb_bin >/dev/null 2>&1 || { echo "ERROR: adb not found" >&2; return 1; }
            echo "Connecting wireless debugging: $CONNECT_HOST:$port"
            st_adb start-server >/dev/null 2>&1 || true
            st_adb connect "$CONNECT_HOST:$port" || return $?
            st_adb -s "$CONNECT_HOST:$port" wait-for-device >/dev/null 2>&1 || return $?
            echo "OK: connected at $CONNECT_HOST:$port"
            return 0
            ;;
    esac
}

is_port() {
    case "$1" in
        ''|*[!0-9]*) return 1 ;;
    esac
    [ "$1" -ge 1 ] 2>/dev/null && [ "$1" -le 65535 ] 2>/dev/null
}
