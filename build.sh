#!/bin/sh
# Gera o pacote .deb do openfortivpn-indicator.
set -e

HERE="$(cd "$(dirname "$0")" && pwd)"
PKG="$HERE/package"

VERSION="$(sed -n 's/^Version: //p' "$PKG/DEBIAN/control")"
OUT="$HERE/openfortivpn-indicator_${VERSION}_all.deb"

# Remove artefatos que não devem ir para o pacote.
find "$PKG" -name '__pycache__' -type d -prune -exec rm -rf {} + 2>/dev/null || true

# Permissões corretas dentro do pacote.
chmod 755 "$PKG/DEBIAN/postinst" "$PKG/DEBIAN/prerm" "$PKG/DEBIAN/postrm"
chmod 755 "$PKG/usr/bin/openfortivpn-indicator"
find "$PKG/usr" "$PKG/etc" -type d -exec chmod 755 {} +
find "$PKG/usr/share" -type f -exec chmod 644 {} +
chmod 644 "$PKG/usr/lib/systemd/system/openfortivpn-indicator.service"
chmod 644 "$PKG/etc/xdg/autostart/openfortivpn-indicator.desktop"

# Tamanho instalado (KiB) no control.
SIZE="$(du -sk "$PKG/usr" "$PKG/etc" | awk '{s+=$1} END{print s}')"
if grep -q '^Installed-Size:' "$PKG/DEBIAN/control"; then
    sed -i "s/^Installed-Size:.*/Installed-Size: $SIZE/" "$PKG/DEBIAN/control"
else
    printf 'Installed-Size: %s\n' "$SIZE" >> "$PKG/DEBIAN/control"
fi

dpkg-deb --root-owner-group --build "$PKG" "$OUT"
echo
echo "Pacote gerado: $OUT"
echo "Instale com:   sudo apt install $OUT"
