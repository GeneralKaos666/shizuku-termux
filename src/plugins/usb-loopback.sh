#!/usr/bin/env bash
# plugin usb-loopback — adb tcpip 5555 + connect 127.0.0.1:5555 (xvxv-stack7).

st_plugin_usb_loopback() {
    echo "usb-loopback: configuring adb tcpip 5555 ..."
    st_adb tcpip 5555 || return $?
    echo "Connecting to 127.0.0.1:5555 ..."
    st_adb connect 127.0.0.1:5555 || return $?
    echo "OK: USB loopback active"
    return 0
}
