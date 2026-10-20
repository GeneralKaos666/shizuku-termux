#!/usr/bin/env bash
# plugin pm-install — pm install via rish (uid 2000), not Termux's pm.
# Does not bypass the Play Store.

st_plugin_pm_install() {
    local apk="$1"
    [ -n "$apk" ] && [ -f "$apk" ] || { echo "ERROR: provide an APK" >&2; return 1; }

    local uid
    uid="$(rish -c id 2>/dev/null || true)"
    case "$uid" in
        *2000*) ;;
        *) echo "ERROR: uid is not 2000 (current: $uid). Refusing pm install." >&2; return 5 ;;
    esac

    echo "Installing $apk via rish (uid 2000) ..."
    rish -c "pm install $(printf '%q' "$apk")" || return $?
    echo "OK: installed"
    return 0
}
