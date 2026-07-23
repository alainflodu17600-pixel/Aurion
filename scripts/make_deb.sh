#!/usr/bin/env bash
set -euo pipefail
PUBLISH_ROOT="$(dirname "$0")/publish"
RID=${1:-linux-x64}
OUTDIR="$PUBLISH_ROOT/$RID"
if [ ! -d "$OUTDIR" ]; then
  echo "Publish directory $OUTDIR not found. Run scripts/publish.sh first." >&2
  exit 1
fi

PKGROOT="$PUBLISH_ROOT/debroot"
rm -rf "$PKGROOT"
mkdir -p "$PKGROOT/DEBIAN" "$PKGROOT/usr/local/aurion"

cat > "$PKGROOT/DEBIAN/control" <<EOF
Package: aurion
Version: 1.0.0
Section: utils
Priority: optional
Architecture: amd64
Maintainer: Aurion <support@aurion.local>
Description: Aurion portable package
EOF

cp -r "$OUTDIR"/* "$PKGROOT/usr/local/aurion/"

dpkg-deb --build "$PKGROOT" "$PUBLISH_ROOT/aurion_1.0.0_amd64.deb"

echo "Created deb: $PUBLISH_ROOT/aurion_1.0.0_amd64.deb"
