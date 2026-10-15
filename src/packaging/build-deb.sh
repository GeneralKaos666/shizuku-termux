#!/usr/bin/env bash
# build-deb.sh — gera .deb do shizuku-termux (ZERO .dex/.so/.apk).
# O .deb contém scripts + man + postinst que lembra `shizuku install`.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' RETURN

DEB_DIR="$WORK/shizuku-termux-1.0.0"
DEBIAN="$DEB_DIR/DEBIAN"
mkdir -p "$DEBIAN" "$DEB_DIR/usr/bin" "$DEB_DIR/usr/lib/shizuku-termux/lib" \
         "$DEB_DIR/usr/lib/shizuku-termux/plugins" \
         "$DEB_DIR/usr/share/man/man1"

# ── control ─────────────────────────────────────────────────────
cp "$SCRIPT_DIR/DEBIAN/control" "$DEBIAN/control"
chmod 644 "$DEBIAN/control"

# ── postinst: lembra rodar `shizuku install` no device ─────────
cat > "$DEBIAN/postinst" <<'POSTINST'
#!/bin/sh
set -e
echo "shizuku-termux instalado."
echo "No device Termux, rode:  shizuku install --apk <caminho-do-apk-shizuku>"
echo "Depois:                  shizuku doctor"
exit 0
POSTINST
chmod 755 "$DEBIAN/postinst"

# ── binários/scripts ────────────────────────────────────────────
cp "$SCRIPT_DIR/../bin/shizuku" "$DEB_DIR/usr/bin/shizuku"
cp "$SCRIPT_DIR/../bin/shk"     "$DEB_DIR/usr/bin/shk"
chmod 755 "$DEB_DIR/usr/bin/shizuku" "$DEB_DIR/usr/bin/shk"

# rish.in (template; o rish real é gerado no device por `shizuku install`)
cp "$SCRIPT_DIR/../bin/rish.in" "$DEB_DIR/usr/lib/shizuku-termux/rish.in"
chmod 644 "$DEB_DIR/usr/lib/shizuku-termux/rish.in"

# libs (sem .dex/.so — só os fontes de shell)
cp "$SCRIPT_DIR/../lib/paths.sh" "$DEB_DIR/usr/lib/shizuku-termux/lib/"
cp "$SCRIPT_DIR/../lib/extract-apk.sh" "$DEB_DIR/usr/lib/shizuku-termux/lib/"
cp "$SCRIPT_DIR/../lib/doctor.sh" "$DEB_DIR/usr/lib/shizuku-termux/lib/"
chmod 644 "$DEB_DIR/usr/lib/shizuku-termux/lib/"*.sh

# plugins de ponte (sem .dex/.so)
cp "$SCRIPT_DIR/../plugins/"*.sh "$DEB_DIR/usr/lib/shizuku-termux/plugins/"
chmod 644 "$DEB_DIR/usr/lib/shizuku-termux/plugins/"*.sh

# ── man page ────────────────────────────────────────────────────
cat > "$DEB_DIR/usr/share/man/man1/shizuku.1" <<'MAN'
.SH NAME
shizuku \- ponte Termux<->Shizuku (núcleo único)

.SH SYNOPSIS
shizuku <verbo> [args]

.SH DESCRIPTION
Instala, valida e usa Shizuku/rish no Termux dentro do protocolo
oficial da Rikka. O pacote .deb N\u00c3O cont\u00c9M .dex/.so/.apk;
a extra\u00e7\u00e3o do DEX acontece no device via \`shizuku install\`.

.SH VERBOS
install      Extrai APK Shizuku \u2192 $PREFIX/lib/shizuku-termux/
doctor       Checa sa\u00fade do n\u00facleo
rish <args>  Passa args ao launcher rish remoto
info|open|stop|exec|shell|version
             Opera\u00e7\u00f5es do Shizuku
uninstall    Remove launcher/dex/symlink
sui          \--backend shizuku|sui
wireless     adb pair/connect IP:porta + c\u00f3digo
usb-loopback adb tcpip 5555 + connect 127.0.0.1:5555
keepalive    Heartbeat (start|stop|status)
pm-install   pm install via rish s\u00f3 se uid 2000
start-daemon start.sh oficial via adb
aliases      spm/sam opcionais

.SH "NAO FAÇA"
tinyurl, curl | bash, gist, .dex/.so no git, chmod +w no DEX,
pkg install shizuku, PKG placeholder.

MAN
gzip -9 "$DEB_DIR/usr/share/man/man1/shizuku.1"

# ── gerar .deb ──────────────────────────────────────────────────
DEB_OUT="/tmp/shizuku-termux-1.0.0.deb"
if command -v dpkg-deb >/dev/null 2>&1; then
    dpkg-deb --root-owner-group -b "$DEB_DIR" "$DEB_OUT"
    echo "OK: .deb gerado em $DEB_OUT"
    echo "---"
    dpkg-deb --info "$DEB_OUT"
else
    echo "AVISO: dpkg-deb n\u00e3o encontrado; .deb n\u00e3o gerado."
    echo "Estrutura pronta em: $DEB_DIR"
    exit 0
fi
