$publish = Join-Path $PSScriptRoot '..\publish'
$publish = (Resolve-Path $publish).Path
if (-not (Test-Path $publish)) {
	Write-Error "Publish directory not found: $publish"
	exit 1
}

$checksumsFile = Join-Path $publish 'checksums.sha256'
Remove-Item -Force -ErrorAction SilentlyContinue $checksumsFile

$files = Get-ChildItem -Path $publish -Recurse -File | Where-Object { $_.Extension -ne '.sha256' -and $_.Name -ne 'checksums.sha256' }

foreach ($f in $files) {
	$h = Get-FileHash -Path $f.FullName -Algorithm SHA256
	$rel = $f.FullName.Substring($publish.Length + 1)
	$line = '{0}  {1}' -f $h.Hash, $rel
	$line | Out-File -FilePath $checksumsFile -Encoding UTF8 -Append
}

# Individual .sha256 files
foreach ($f in $files) {
	$h = Get-FileHash -Path $f.FullName -Algorithm SHA256
	$shaFile = $f.FullName + '.sha256'
	$h.Hash | Out-File -FilePath $shaFile -Encoding ASCII
}

Write-Host "Checksums generated: $checksumsFile"
