#!/usr/bin/env bash
set -euo pipefail

CONFIGURATION=Release
RIDS=(win-x86 win-x64 linux-x64 linux-arm64 osx-x64)
PUBLISH_ROOT="$(dirname "$0")/publish"
mkdir -p "$PUBLISH_ROOT"

for rid in "${RIDS[@]}"; do
  echo "Publishing for $rid"
  dotnet publish "Aurion/Aurion.csproj" -c $CONFIGURATION -r $rid --self-contained true -p:PublishSingleFile=true -p:PublishTrimmed=false -o "$PUBLISH_ROOT/$rid"
  dotnet publish "src/Aurion.Host/Aurion.Host.csproj" -c $CONFIGURATION -r $rid --self-contained false -o "$PUBLISH_ROOT/${rid}-host"
  dotnet publish "src/Aurion.API/Aurion.API.csproj" -c $CONFIGURATION -r $rid --self-contained false -o "$PUBLISH_ROOT/${rid}-api"

  if [[ $rid == win-* ]]; then
    zip -r "$PUBLISH_ROOT/${rid}.zip" "$PUBLISH_ROOT/$rid"
    echo "Created $PUBLISH_ROOT/${rid}.zip"
  else
    tar -C "$PUBLISH_ROOT/$rid" -czf "$PUBLISH_ROOT/${rid}.tar.gz" .
    echo "Created $PUBLISH_ROOT/${rid}.tar.gz"
  fi
done

echo "Publish complete. Artifacts in $PUBLISH_ROOT"
