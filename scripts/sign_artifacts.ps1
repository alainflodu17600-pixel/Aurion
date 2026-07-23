<#
Script de signature des artefacts (PowerShell)
Usage:
  - Définir les variables d'environnement :
	  $env:SIGN_CERT_PATH -> chemin vers le fichier .pfx
	  $env:SIGN_CERT_PASSWORD -> mot de passe
  - Exécuter : powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\sign_artifacts.ps1

Remarque : ce script utilise `signtool.exe` (Windows SDK). Si signtool n'est pas disponible, le script affiche les instructions.
#>

$publishDir = Join-Path $PSScriptRoot '..' | Resolve-Path | ForEach-Object { Join-Path $_ 'publish' }
$publishDir = [IO.Path]::GetFullPath($publishDir)
Write-Host "Publish dir: $publishDir"

if (-not (Test-Path $publishDir)) {
	Write-Error "Répertoire $publishDir introuvable. Exécutez d'abord scripts/publish.ps1"
	exit 1
}

$signtool = Get-Command signtool.exe -ErrorAction SilentlyContinue
if (-not $signtool) {
	Write-Warning "signtool.exe non trouvé. Installez Windows SDK (Include Signing Tools). Le script créera uniquement les checksums."
	exit 0
}

$pfx = $env:SIGN_CERT_PATH
$pwd = $env:SIGN_CERT_PASSWORD
if (-not $pfx -or -not (Test-Path $pfx)) {
	Write-Error "Aucun certificat PFX trouvé. Définissez SIGN_CERT_PATH et SIGN_CERT_PASSWORD comme variables d'environnement."
	exit 1
}

Get-ChildItem -Path $publishDir -Recurse -File | ForEach-Object {
	$file = $_.FullName
	Write-Host "Signing $file"
	& $signtool "sign" "/f" "$pfx" "/p" "$pwd" "/fd" "SHA256" "/tr" "http://timestamp.digicert.com" "/td" "SHA256" "$file"
}

Write-Host "Signature terminée."
