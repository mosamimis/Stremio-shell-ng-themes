# Method 2 (edit your own): copy the edited themes.js into the shell, rebuild, install, restart Stremio.
# Usage: powershell -ExecutionPolicy Bypass -File "$HOME\update-stremio.ps1"
Copy-Item "$HOME\Downloads\themes.js" "$HOME\stremio-shell-ng\src\stremio_app\themes.js" -Force
Set-Location "$HOME\stremio-shell-ng"
cargo build --release
if ($LASTEXITCODE -ne 0) { Write-Host "Build failed" -ForegroundColor Red; return }
Get-Process stremio* -ErrorAction SilentlyContinue | Stop-Process -Force
Start-Sleep -Seconds 1
Copy-Item "$HOME\stremio-shell-ng\target\release\stremio-shell-ng.exe" "$env:LOCALAPPDATA\Programs\Stremio\stremio-shell-ng.exe" -Force
Start-Process "$env:LOCALAPPDATA\Programs\Stremio\stremio-shell-ng.exe"
Write-Host "Updated" -ForegroundColor Green
