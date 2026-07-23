param(
	[string]$Configuration = "Release",
	[string[]]$Runtimes = @('win-x86','win-x64','linux-x64','linux-arm64','osx-x64')
)

$projectRoot = Split-Path -Parent $PSScriptRoot
$publishRoot = Join-Path $projectRoot 'publish'
New-Item -ItemType Directory -Force -Path $publishRoot | Out-Null

foreach ($rid in $Runtimes) {
	Write-Host "Publishing for runtime: $rid"
	# Main app
	dotnet publish "Aurion/Aurion.csproj" -c $Configuration -r $rid --self-contained true -p:PublishSingleFile=true -p:PublishTrimmed=false -o (Join-Path $publishRoot $rid)

	# Host and API (framework dependent) - produce framework-dependent builds to run on platforms with dotnet
	dotnet publish "src/Aurion.Host/Aurion.Host.csproj" -c $Configuration -r $rid --self-contained false -o (Join-Path $publishRoot "$rid-host")
	dotnet publish "src/Aurion.API/Aurion.API.csproj" -c $Configuration -r $rid --self-contained false -o (Join-Path $publishRoot "$rid-api")

	# Package as archive
	$outDir = Join-Path $publishRoot $rid
	if ($rid -like 'win-*') {
		$zipPath = Join-Path $publishRoot "$rid.zip"
		if (Test-Path $zipPath) { Remove-Item $zipPath }
		Compress-Archive -Path $outDir\* -DestinationPath $zipPath
		Write-Host "Created $zipPath"
	} else {
		$tarPath = Join-Path $publishRoot "$rid.tar.gz"
		if (Test-Path $tarPath) { Remove-Item $tarPath }
		tar -czf $tarPath -C $outDir .
		Write-Host "Created $tarPath"
	}
}

Write-Host "Publish complete. Artifacts in $publishRoot"
