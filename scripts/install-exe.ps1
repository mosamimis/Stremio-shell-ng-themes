# Method 1 (app copy): put the ready-made stremio-shell-ng.exe into Stremio.
# 1) Install Stremio once:  winget install -e --id Stremio.Stremio
# 2) Download stremio-shell-ng.exe from this repo's Releases into your Downloads folder
# 3) Run:  powershell -ExecutionPolicy Bypass -File .\install-exe.ps1
$src = "$HOME\Downloads\stremio-shell-ng.exe"
$dst = "$env:LOCALAPPDATA\Programs\Stremio"
if (-not (Test-Path $src)) { Write-Host "stremio-shell-ng.exe not found in Downloads" -ForegroundColor Red; return }
if (-not (Test-Path $dst)) { Write-Host "Stremio is not installed. Run: winget install -e --id Stremio.Stremio" -ForegroundColor Red; return }
Get-Process stremio* -ErrorAction SilentlyContinue | Stop-Process -Force
Start-Sleep -Seconds 1
if (Test-Path "$dst\stremio-shell-ng.exe") { Copy-Item "$dst\stremio-shell-ng.exe" "$dst\stremio-shell-ng.original.exe" -Force }
Copy-Item $src "$dst\stremio-shell-ng.exe" -Force
Start-Process "$dst\stremio-shell-ng.exe"
Write-Host "Installed. The original was kept as stremio-shell-ng.original.exe" -ForegroundColor Green
