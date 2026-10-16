#!/usr/bin/env bash
# build-deb.sh — builds the shizuku-termux .deb (ZERO .dex/.so/.apk).
# The .deb contains scripts + man + postinst that reminds you to run `shizuku install`.
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

# ── postinst: reminds you to run `shizuku install` on the device ─
cat > "$DEBIAN/postinst" <<'POSTINST'
#!/bin/sh
set -e
echo "shizuku-termux installed."
echo "On the Termux device, run:  shizuku install --apk <path-to-shizuku-apk>"
echo "Then:                       shizuku doctor"
exit 0
POSTINST
chmod 755 "$DEBIAN/postinst"

# ── binaries/scripts ────────────────────────────────────────────
cp "$SCRIPT_DIR/../bin/shizuku" "$DEB_DIR/usr/bin/shizuku"
cp "$SCRIPT_DIR/../bin/shk"     "$DEB_DIR/usr/bin/shk"
chmod 755 "$DEB_DIR/usr/bin/shizuku" "$DEB_DIR/usr/bin/shk"

# rish.in (template; the real rish is generated on the device by `shizuku install`)
cp "$SCRIPT_DIR/../bin/rish.in" "$DEB_DIR/usr/lib/shizuku-termux/rish.in"
chmod 644 "$DEB_DIR/usr/lib/shizuku-termux/rish.in"

# libs (no .dex/.so — shell sources only)
cp "$SCRIPT_DIR/../lib/paths.sh" "$DEB_DIR/usr/lib/shizuku-termux/lib/"
cp "$SCRIPT_DIR/../lib/extract-apk.sh" "$DEB_DIR/usr/lib/shizuku-termux/lib/"
cp "$SCRIPT_DIR/../lib/doctor.sh" "$DEB_DIR/usr/lib/shizuku-termux/lib/"
chmod 644 "$DEB_DIR/usr/lib/shizuku-termux/lib/"*.sh

# bridge plugins (no .dex/.so)
cp "$SCRIPT_DIR/../plugins/"*.sh "$DEB_DIR/usr/lib/shizuku-termux/plugins/"
chmod 644 "$DEB_DIR/usr/lib/shizuku-termux/plugins/"*.sh

# ── man page ────────────────────────────────────────────────────
cat > "$DEB_DIR/usr/share/man/man1/shizuku.1" <<'MAN'
.SH NAME
shizuku \- Termux<->Shizuku bridge (single core)

.SH SYNOPSIS
shizuku <verb> [args]

.SH DESCRIPTION
Installs, validates and uses Shizuku/rish in Termux within the official
Rikka protocol. The .deb package does NOT contain .dex/.so/.apk;
the DEX extraction happens on the device via \`shizuku install\`.

.SH VERBS
install      Extracts Shizuku APK → $PREFIX/lib/shizuku-termux/
doctor       Checks core health
rish <args>  Passes args to the remote rish launcher
info|open|stop|exec|shell|version
             Shizuku operations
uninstall    Removes launcher/dex/symlink
sui          \--backend shizuku|sui
wireless     adb pair/connect IP:port + code
usb-loopback adb tcpip 5555 + connect 127.0.0.1:5555
keepalive    Heartbeat (start|stop|status)
pm-install   pm install via rish only if uid 2000
start-daemon Official start.sh via adb
aliases      Optional spm/sam

.SH "DO NOT"
tinyurl, curl | bash, gist, .dex/.so in git, chmod +w on the DEX,
pkg install shizuku, PKG placeholder.

MAN
gzip -9 "$DEB_DIR/usr/share/man/man1/shizuku.1"

# ── build the .deb ──────────────────────────────────────────────
DEB_OUT="/tmp/shizuku-termux-1.0.0.deb"
if command -v dpkg-deb >/dev/null 2>&1; then
    dpkg-deb --root-owner-group -b "$DEB_DIR" "$DEB_OUT"
    echo "OK: .deb generated at $DEB_OUT"
    echo "---"
    dpkg-deb --info "$DEB_OUT"
else
    echo "WARNING: dpkg-deb not found; .deb not generated."
    echo "Structure ready at: $DEB_DIR"
    exit 0
fi
