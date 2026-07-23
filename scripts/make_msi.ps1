<#
Génère un MSI à partir de l'archive publish\<rid>. Utilise WiX (candle.exe & light.exe).
Usage: powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\make_msi.ps1 -Rid win-x64
#>
param(
	[string]$Rid = 'win-x64'
)

$publish = Join-Path $PSScriptRoot '..' | Resolve-Path | ForEach-Object { Join-Path $_ 'publish' }
$publish = [IO.Path]::GetFullPath($publish)
$out = Join-Path $publish "$Rid-msi"
New-Item -ItemType Directory -Force -Path $out | Out-Null

# Basic WiX template
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
	  <Component Id='MainFiles' Guid='*'>
		<File Source='[SOURCE_PLACEHOLDER]' />
	  </Component>
	</DirectoryRef>
	<Feature Id='DefaultFeature' Level='1'>
	  <ComponentRef Id='MainFiles' />
	</Feature>
  </Product>
</Wix>
"@

# Find main file to package (pick published single file or folder)
$ridDir = Join-Path $publish $Rid
if (-not (Test-Path $ridDir)) {
	Write-Error "Publish directory $ridDir not found"
	exit 1
}

# For simplicity we will include the zip or first exe
$zip = Join-Path $publish "$Rid.zip"
$exe = Get-ChildItem -Path $ridDir -Filter *.exe -Recurse -File | Select-Object -First 1
$sourcePlaceholderPath = $zip
if ($exe) { $sourcePlaceholderPath = $exe.FullName }

$wxs = $wxs -replace '\[SOURCE_PLACEHOLDER\]', ($sourcePlaceholderPath -replace '\\','\\\\')
$outWxs = Join-Path $out 'Aurion.wxs'
$wxs | Out-File -FilePath $outWxs -Encoding UTF8

# Check WiX tools
$candle = Get-Command candle.exe -ErrorAction SilentlyContinue
$light = Get-Command light.exe -ErrorAction SilentlyContinue
if (-not $candle -or -not $light) {
	Write-Error "WiX tools non trouvés. Installez WiX Toolset (candle.exe & light.exe) pour construire le MSI."
	Write-Host "WXS template créé : $outWxs"
	exit 1
}

Push-Location $out
& $candle $outWxs
& $light -out "Aurion.msi" "Aurion.wixobj"
Pop-Location

Write-Host "MSI créé : $out\Aurion.msi"
