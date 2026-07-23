Param(
	[string]$Configuration = "Release",
	[string]$Runtime = "win-x64"
)

$publishDir = Join-Path (Split-Path -Parent $PSScriptRoot) "publish\$Runtime"
if (-not (Test-Path $publishDir)) {
	Write-Error "Publish directory not found: $publishDir. Run scripts/publish.ps1 first."
	exit 1
}

# Create portable ZIP
$zipPath = Join-Path (Split-Path -Parent $PSScriptRoot) "publish\$Runtime.zip"
if (Test-Path $zipPath) { Remove-Item $zipPath }
Compress-Archive -Path (Join-Path $publishDir "*") -DestinationPath $zipPath -Force
Write-Host "Created portable ZIP: $zipPath"

# If WiX is installed, produce an MSI (requires candle.exe and light.exe in PATH)
if (Get-Command candle.exe -ErrorAction SilentlyContinue) {
	Write-Host "WiX toolset detected: generating MSI (requires WiX toolset project template or .wxs file)."
	# Placeholder: user must provide Product.wxs or we can create a basic template
	$wxs = @"
<?xml version='1.0' encoding='UTF-8'?>
<Wix xmlns='http://schemas.microsoft.com/wix/2006/wi'>
  <Product Id='*' Name='Aurion' Language='1036' Version='1.0.0.0' Manufacturer='Aurion' UpgradeCode='PUT-GUID-HERE'>
	<Package InstallerVersion='500' Compressed='yes' InstallScope='perMachine' />
	<MediaTemplate />
	<Directory Id='TARGETDIR' Name='SourceDir'>
	  <Directory Id='ProgramFilesFolder'>
		<Directory Id='INSTALLFOLDER' Name='Aurion' />
	  </Directory>
	</Directory>
	<DirectoryRef Id='INSTALLFOLDER'>
	  <Component Id='MainExecutable' Guid='*'>
		<File Source='${zipPath}' />
	  </Component>
	</DirectoryRef>
	<Feature Id='DefaultFeature' Level='1'>
	  <ComponentRef Id='MainExecutable' />
	</Feature>
  </Product>
</Wix>
"@
	$wxsPath = Join-Path $publishDir "Aurion.wxs"
	$wxs | Out-File -FilePath $wxsPath -Encoding UTF8
	Push-Location $publishDir
	candle.exe $wxsPath
	light.exe -out "Aurion.msi" "Aurion.wixobj"
	Pop-Location
	Write-Host "MSI built at: $publishDir\Aurion.msi"
} else {
	Write-Host "WiX not found; MSI generation skipped. Provide WiX toolset to build MSI."
}
