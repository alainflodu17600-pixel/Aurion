#!/usr/bin/env bash
PROJECT=${1:-src/Aurion.Host/Aurion.Host.csproj}

echo "Running project: $PROJECT"

dotnet run --project "$PROJECT"
