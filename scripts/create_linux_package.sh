#!/usr/bin/env bash
set -euo pipefail
PUBLISH_ROOT="$(dirname "$0")/publish"
RID=${1:-linux-x64}
OUTDIR="$PUBLISH_ROOT/$RID"

if [ ! -d "$OUTDIR" ]; then
  echo "Publish directory $OUTDIR not found. Run scripts/publish.sh first." >&2
  exit 1
fi

TARPATH="$PUBLISH_ROOT/${RID}.tar.gz"
rm -f "$TARPATH"
tar -C "$OUTDIR" -czf "$TARPATH" .

echo "Created package: $TARPATH"

# Optional: create deb package if dpkg-deb is available
if command -v dpkg-deb >/dev/null 2>&1; then
  echo "dpkg-deb found; creating simple .deb package (requires root to install)."
  PKGROOT="$PUBLISH_ROOT/debroot"
  rm -rf "$PKGROOT"
  mkdir -p "$PKGROOT/DEBIAN" "$PKGROOT/usr/local/bin"
  cat > "$PKGROOT/DEBIAN/control" <<EOF
Package: aurion
Version: 1.0.0
Section: utils
Priority: optional
Architecture: amd64
Maintainer: Aurion <support@aurion.local>
Description: Aurion portable package
EOF
  cp -r "$OUTDIR"/* "$PKGROOT/usr/local/bin/"
  dpkg-deb --build "$PKGROOT" "$PUBLISH_ROOT/aurion_1.0.0_amd64.deb"
  echo "Created deb: $PUBLISH_ROOT/aurion_1.0.0_amd64.deb"
fi
