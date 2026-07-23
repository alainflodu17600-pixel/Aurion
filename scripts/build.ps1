param([string]$Configuration = "Debug")

Write-Host "Building solution Aurion.slnx ($Configuration)"

dotnet restore "Aurion.slnx"
dotnet build "Aurion.slnx" -c $Configuration
