#!/usr/bin/env bash
CONFIGURATION=${1:-Debug}

echo "Building Aurion.slnx ($CONFIGURATION)"

dotnet restore "Aurion.slnx"
dotnet build "Aurion.slnx" -c $CONFIGURATION
