# AURION

Système d'intelligence universelle auto-évolutif — structure initiale.

Structure créée :
- src/Aurion.Core (Class Library)
- src/Aurion.Host (Console Host)
- src/Aurion.API (ASP.NET Core minimal API)
- src/Aurion.Security (Class Library)
- tests/Aurion.Tests (xUnit)

Commandes utiles :
- dotnet build "Aurion.slnx"
- dotnet run --project src/Aurion.Host/Aurion.Host.csproj
- dotnet run --project src/Aurion.API/Aurion.API.csproj

Publier des artefacts (exemples)
- PowerShell (Windows) : powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\publish.ps1
- Bash (Linux/macOS) : ./scripts/publish.sh

Les scripts produisent des builds self-contained pour : win-x86, win-x64, linux-x64, linux-arm64, osx-x64 et créent des archives ZIP / tar.gz dans ./publish.

Installer / packager
- Windows portable : fournir le ZIP produit (scripts/create_windows_installer.ps1 crée un ZIP et propose un squelette MSI si WiX est installé).
- Linux : tar.gz ou .deb (scripts/create_linux_package.sh crée tar.gz et un .deb si dpkg-deb est disponible).
- macOS : tar.gz ou DMG (DMG script non inclus; hdiutil peut être utilisé sur macOS).

CI
- Un workflow GitHub Actions est présent (.github/workflows/ci.yml) pour build/test/publish multi-RID et upload des artefacts.

Notes sur l'état actuel
- Build Release : OK
- Tests : la suite de tests ne contient pas de tests exécutables (0 tests découverts). Ajouter des tests unitaires recommandée.
- Artefacts publiés trouvés dans ./publish (ex. publish/win-x64, publish/osx-x64.tar.gz).

Prochaines étapes suggérées :
1. Ajouter des tests fonctionnels et unitaires (tests/Aurion.Tests actuellement vide/à configurer).
2. Si vous voulez des installateurs signés ou MSI/DEB/DMG automatiques, installez les outils WiX/dpkg-deb/hdiutil sur la machine CI et je peux activer la génération automatique.
3. Souhaitez-vous que je crée les installeurs MSI/DEB/DMG automatiquement sur cette machine (si outils présents) ou que je fournisse uniquement les archives portables ?
