#!/usr/bin/env bash
# plugin pm-install — pm install via rish (uid 2000), não o pm do Termux.
# Não bypassa Play Store.

st_plugin_pm_install() {
    local apk="$1"
    [ -n "$apk" ] && [ -f "$apk" ] || { echo "ERRO: informe um APK" >&2; return 1; }

    local uid
    uid="$(rish -c id 2>/dev/null || true)"
    case "$uid" in
        *2000*) ;;
        *) echo "ERRO: uid não é 2000 (atual: $uid). Recusando pm install." >&2; return 5 ;;
    esac

    echo "Instalando $apk via rish (uid 2000) ..."
    rish -c "pm install $(printf '%q' "$apk")" || return $?
    echo "OK: instalado"
    return 0
}
