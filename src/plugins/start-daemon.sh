#!/usr/bin/env bash
# plugin start-daemon — official Shizuku daemon start via adb.
# Does not replace the app; does not install rish.
# Fallback: official start.sh → libshizuku.so --apk= → libshizuku.so start.

st_plugin_start_daemon() {
    echo "Starting Shizuku daemon via adb ..."

    if st_adb shell sh /sdcard/Android/data/moe.shizuku.privileged.api/start.sh >/dev/null 2>&1; then
        echo "OK: official start.sh sent (verify with 'shizuku doctor')"
        return 0
    fi
    echo "WARNING: official start.sh failed, trying libshizuku.so ..." >&2

    local apk_path apk_dir native_dir lib_path candidate abi
    apk_path="$(st_adb shell pm path moe.shizuku.privileged.api 2>/dev/null | sed 's/^package://' | tr -d '\r' | grep -E '/base\.apk$' | head -1)"
    if [ -z "$apk_path" ]; then
        apk_path="$(st_adb shell pm path moe.shizuku.privileged.api 2>/dev/null | sed 's/^package://' | tr -d '\r' | head -1)"
    fi
    [ -n "$apk_path" ] || { echo "ERROR: could not locate APK via pm path" >&2; return 1; }

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

    [ -n "$lib_path" ] || { echo "ERROR: libshizuku.so not found" >&2; return 1; }

    if st_adb shell "$lib_path" --apk="$apk_path" >/dev/null 2>&1; then
        echo "OK: libshizuku.so --apk=$apk_path sent (verify with 'shizuku doctor')"
        return 0
    fi
    echo "WARNING: libshizuku.so --apk= failed, trying libshizuku.so start ..." >&2

    if st_adb shell "$lib_path" start >/dev/null 2>&1; then
        echo "OK: libshizuku.so start sent (verify with 'shizuku doctor')"
        return 0
    fi

    echo "ERROR: all start attempts failed" >&2
    return 1
}
