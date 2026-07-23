param([string]$Project = "src/Aurion.Host/Aurion.Host.csproj")

Write-Host "Running project: $Project"

dotnet run --project $Project
