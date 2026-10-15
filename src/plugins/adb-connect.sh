#!/usr/bin/env bash
# plugin adb-connect — debug sem fio em 127.0.0.1, sem tcpip.
# Companheiro do wireless.sh (que recusa 127.0.0.1 e foca LAN).
# Não copia scripts do QuickShell; reimplementado.

CONNECT_HOST="127.0.0.1"

st_plugin_adb_connect() {
    local mode="${1:-}"

    case "$mode" in
        pair)
            local porta="$2" codigo="$3"
            [ -n "$porta" ] && [ -n "$codigo" ] || { echo "ERRO: uso: adb-connect pair <porta> <codigo>" >&2; return 1; }
            is_port "$porta" || { echo "ERRO: porta invalida: $porta" >&2; return 1; }
            st_adb_bin >/dev/null 2>&1 || { echo "ERRO: adb nao encontrado" >&2; return 1; }
            echo "Emparelhando wireless: $CONNECT_HOST:$porta"
            st_adb pair "$CONNECT_HOST:$porta" "$codigo" || return $?
            echo "OK: emparelhado em $CONNECT_HOST:$porta"
            return 0
            ;;
        status)
            st_adb_bin >/dev/null 2>&1 || { echo "ERRO: adb nao encontrado" >&2; return 1; }
            echo "Dispositivos ADB:"
            st_adb devices
            return 0
            ;;
        disconnect)
            local porta="${2:-5555}"
            is_port "$porta" || { echo "ERRO: porta invalida: $porta" >&2; return 1; }
            st_adb_bin >/dev/null 2>&1 || { echo "ERRO: adb nao encontrado" >&2; return 1; }
            echo "Desconectando: $CONNECT_HOST:$porta"
            st_adb disconnect "$CONNECT_HOST:$porta" || return $?
            echo "OK: desconectado"
            return 0
            ;;
        wf)
            echo "Abrindo configuracao de debug sem fio (Wireless Debugging) via rish ..."
            if st_rish -c 'am start -a android.settings.APPLICATION_DEVELOPMENT_SETTINGS --es ":settings:fragment_args_key" toggle_adb_wireless' >/dev/null 2>&1; then
                echo "OK: pagina de debug sem fio aberta via rish"
                return 0
            fi
            if st_rish -c 'am start -a android.settings.DEVELOPMENT_SETTINGS' >/dev/null 2>&1; then
                echo "OK: pagina de desenvolvedor aberta via rish"
                return 0
            fi
            echo "ERRO: nao foi possível abrir configuracao de desenvolvedor via rish" >&2
            return 1
            ;;
        ""|*)
            local porta="$mode"
            [ -n "$porta" ] || { echo "ERRO: uso: adb-connect <porta> | pair <porta> <codigo> | status | disconnect [porta] | wf" >&2; return 1; }
            is_port "$porta" || { echo "ERRO: porta invalida: $porta" >&2; return 1; }
            st_adb_bin >/dev/null 2>&1 || { echo "ERRO: adb nao encontrado" >&2; return 1; }
            echo "Conectando debug sem fio: $CONNECT_HOST:$porta"
            st_adb start-server >/dev/null 2>&1 || true
            st_adb connect "$CONNECT_HOST:$porta" || return $?
            st_adb -s "$CONNECT_HOST:$porta" wait-for-device >/dev/null 2>&1 || return $?
            echo "OK: conectado em $CONNECT_HOST:$porta"
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
