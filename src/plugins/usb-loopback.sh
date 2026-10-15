#!/usr/bin/env bash
# plugin usb-loopback — adb tcpip 5555 + connect 127.0.0.1:5555 (xvxv-stack7).

st_plugin_usb_loopback() {
    echo "usb-loopback: configurando adb tcpip 5555 ..."
    adb tcpip 5555 || return $?
    echo "Conectando em 127.0.0.1:5555 ..."
    adb connect 127.0.0.1:5555 || return $?
    echo "OK: loopback USB ativo"
    return 0
}
