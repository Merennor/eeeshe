#!/bin/sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
VERSION=${1:-$(sed -n 's/^Version: //p' "$ROOT/packaging/debian/control")}
PKG="eeeshe_${VERSION}_all.deb"
STAGE=$(mktemp -d)
trap 'rm -rf "$STAGE"' EXIT
install -Dm644 "$ROOT/packaging/debian/control" "$STAGE/DEBIAN/control"
sed -i "s/^Version: .*/Version: $VERSION/" "$STAGE/DEBIAN/control"
install -Dm755 "$ROOT/packaging/debian/postinst" "$STAGE/DEBIAN/postinst"
install -Dm755 "$ROOT/packaging/debian/postrm" "$STAGE/DEBIAN/postrm"
install -Dm755 "$ROOT/she-cycle.sh" "$STAGE/usr/bin/she-cycle"
install -Dm644 "$ROOT/she" "$STAGE/usr/share/doc/eeeshe/she"
install -Dm644 "$ROOT/README.md" "$STAGE/usr/share/doc/eeeshe/README.md"
mkdir -p "$STAGE/etc/acpi/actions" "$STAGE/etc/acpi/events"
ln -s /usr/bin/she-cycle "$STAGE/etc/acpi/actions/she-cycle.sh"
install -Dm644 "$ROOT/she" "$STAGE/etc/acpi/events/she"
dpkg-deb --root-owner-group --build "$STAGE" "$ROOT/$PKG"
printf 'Created %s\n' "$ROOT/$PKG"
