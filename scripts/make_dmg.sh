#!/usr/bin/env bash
set -euo pipefail
PUBLISH_ROOT="$(dirname "$0")/publish"
RID=${1:-osx-x64}
OUTDIR="$PUBLISH_ROOT/$RID"
if [ ! -d "$OUTDIR" ]; then
  echo "Publish directory $OUTDIR not found. Run scripts/publish.sh first." >&2
  exit 1
fi

DMGNAME="Aurion.dmg"

echo "Creating DMG from $OUTDIR -> $PUBLISH_ROOT/$DMGNAME"

hdiutil create -volname Aurion -srcfolder "$OUTDIR" -ov -format UDZO "$PUBLISH_ROOT/$DMGNAME"

echo "Created DMG: $PUBLISH_ROOT/$DMGNAME"
