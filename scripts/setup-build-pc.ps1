# Method 2, first time on a new PC: install the tools, get the source, build once.
# Run in PowerShell:  powershell -ExecutionPolicy Bypass -File .\setup-build-pc.ps1
# Then close and reopen PowerShell once (so cargo and git are found) and run it again if the build step failed.
param([string]$Repo = "https://github.com/YOUR-USER/stremio-shell-ng.git")
winget install -e --id Stremio.Stremio
winget install -e --id Git.Git
winget install -e --id Rustlang.Rustup
winget install -e --id Microsoft.VisualStudio.2022.BuildTools --override "--wait --passive --add Microsoft.VisualStudio.Workload.VCTools --includeRecommended"
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User") + ";$HOME\.cargo\bin"
rustup default stable
if (-not (Test-Path "$HOME\stremio-shell-ng")) { git clone $Repo "$HOME\stremio-shell-ng" }
Copy-Item "$PSScriptRoot\update-stremio.ps1" "$HOME\update-stremio.ps1" -Force
Copy-Item "$PSScriptRoot\..\themes.js" "$HOME\Downloads\themes.js" -Force
& "$HOME\update-stremio.ps1"
