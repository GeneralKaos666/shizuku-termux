#!/usr/bin/env bash
# plugin start-daemon — start oficial do daemon Shizuku via adb.
# Não substitui a app; não instala rish.
# Fallback: start.sh oficial → libshizuku.so --apk= → libshizuku.so start.

st_plugin_start_daemon() {
    echo "Iniciando daemon Shizuku via adb ..."

    if st_adb shell sh /sdcard/Android/data/moe.shizuku.privileged.api/start.sh >/dev/null 2>&1; then
        echo "OK: start.sh oficial enviado (verifique com 'shizuku doctor')"
        return 0
    fi
    echo "AVISO: start.sh oficial falhou, tentando libshizuku.so ..." >&2

    local apk_path apk_dir native_dir lib_path candidate abi
    apk_path="$(st_adb shell pm path moe.shizuku.privileged.api 2>/dev/null | sed 's/^package://' | tr -d '\r' | grep -E '/base\.apk$' | head -1)"
    if [ -z "$apk_path" ]; then
        apk_path="$(st_adb shell pm path moe.shizuku.privileged.api 2>/dev/null | sed 's/^package://' | tr -d '\r' | head -1)"
    fi
    [ -n "$apk_path" ] || { echo "ERRO: não foi possível localizar APK via pm path" >&2; return 1; }

    apk_dir="$(dirname "$apk_path")"

    native_dir="$(st_adb shell dumpsys package moe.shizuku.privileged.api 2>/dev/null | grep -i 'nativeLibraryDir' | head -1 | sed 's/.*=//' | tr -d '\r')"
    lib_path=""
    if [ -n "$native_dir" ]; then
        candidate="${native_dir}/libshizuku.so"
        if st_adb shell test -f "$candidate" >/dev/null 2>&1; then
            lib_path="$candidate"
        fi
    fi

    if [ -z "$lib_path" ]; then
        for abi in arm64-v8a armeabi-v7a arm64 arm x86_64 x86; do
            candidate="${apk_dir}/lib/${abi}/libshizuku.so"
            if st_adb shell test -f "$candidate" >/dev/null 2>&1; then
                lib_path="$candidate"
                break
            fi
        done
    fi

    [ -n "$lib_path" ] || { echo "ERRO: libshizuku.so não encontrada" >&2; return 1; }

    if st_adb shell "$lib_path" --apk="$apk_path" >/dev/null 2>&1; then
        echo "OK: libshizuku.so --apk=$apk_path enviado (verifique com 'shizuku doctor')"
        return 0
    fi
    echo "AVISO: libshizuku.so --apk= falhou, tentando libshizuku.so start ..." >&2

    if st_adb shell "$lib_path" start >/dev/null 2>&1; then
        echo "OK: libshizuku.so start enviado (verifique com 'shizuku doctor')"
        return 0
    fi

    echo "ERRO: todas as tentativas de start falharam" >&2
    return 1
}
