[CmdletBinding()]
param(
    [string]$ThemeFile,
    [string]$SourceDir = (Join-Path $HOME 'stremio-shell-ng-method2'),
    [string]$InstallDir = (Join-Path $env:LOCALAPPDATA 'Programs\Stremio')
)
$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'

function Invoke-Native {
    param([Parameter(Mandatory)][string]$FilePath, [Parameter(Mandatory)][string[]]$Arguments)
    & $FilePath @Arguments
    if ($LASTEXITCODE -ne 0) { throw "$FilePath failed with exit code $LASTEXITCODE." }
}

try {
    if (-not $ThemeFile) {
        foreach ($candidate in @((Join-Path $PSScriptRoot 'themes.js'), (Join-Path $PSScriptRoot 'themes(3).js'), (Join-Path $HOME 'Downloads\themes.js'), (Join-Path $HOME 'Downloads\themes(3).js'))) {
            if (Test-Path -LiteralPath $candidate -PathType Leaf) { $ThemeFile = $candidate; break }
        }
    }
    if (-not $ThemeFile -or -not (Test-Path -LiteralPath $ThemeFile -PathType Leaf)) { throw 'Theme file not found. Put themes.js beside this script or in Downloads, or pass -ThemeFile with its full path.' }
    if ((Get-Item -LiteralPath $ThemeFile).Length -eq 0) { throw "The theme file is empty: $ThemeFile" }
    if (-not (Get-Command git.exe -ErrorAction SilentlyContinue)) { throw 'Git was not found on PATH.' }
    if (-not (Get-Command cargo.exe -ErrorAction SilentlyContinue)) { throw 'Cargo was not found on PATH. Install Rust (rustup) and reopen PowerShell.' }

    $SourceDir = [IO.Path]::GetFullPath($SourceDir)
    if (-not (Test-Path -LiteralPath $SourceDir)) {
        New-Item -ItemType Directory -Path (Split-Path -Parent $SourceDir) -Force | Out-Null
        Write-Host "Cloning official Stremio shell source into $SourceDir..."
        Invoke-Native -FilePath 'git.exe' -Arguments @('clone', '--depth', '1', 'https://github.com/Stremio/stremio-shell-ng.git', $SourceDir)
    } elseif (-not (Test-Path -LiteralPath (Join-Path $SourceDir '.git'))) {
        throw "SourceDir exists but is not a Git checkout: $SourceDir. Choose another -SourceDir or move that folder yourself."
    }

    $rustFile = Join-Path $SourceDir 'src\stremio_app\stremio_wevbiew\wevbiew.rs'
    if (-not (Test-Path -LiteralPath $rustFile)) { throw "Expected upstream WebView source file was not found: $rustFile. The upstream source layout may have changed." }
    $rust = [IO.File]::ReadAllText($rustFile)
    $marker = '// METHOD2_THEME_INJECTION'
    if (-not $rust.Contains($marker)) {
        $pattern = '(?m)^([ \t]*)Ok\(\(\)\)(\r?\n)([ \t]*)\}\)\.expect\("Cannot add content loading"\);'
        $matches = [regex]::Matches($rust, $pattern)
        if ($matches.Count -ne 1) { throw 'Could not safely find the WebView theme hook; no Rust source was changed.' }
        $m = $matches[0]
        $indent = $m.Groups[1].Value
        $newline = $m.Groups[2].Value
        $closeIndent = $m.Groups[3].Value
        $insert = $indent + $marker + $newline +
            $indent + 'if let Err(error) = wv.execute_script(include_str!("../themes.js"), |_| Ok(())) {' + $newline +
            $indent + '    eprintln!("Failed to inject custom theme: {error}");' + $newline +
            $indent + '}' + $newline +
            $indent + 'Ok(())' + $newline + $closeIndent + '}).expect("Cannot add content loading");'
        $rust = $rust.Substring(0, $m.Index) + $insert + $rust.Substring($m.Index + $m.Length)
        [IO.File]::WriteAllText($rustFile, $rust, (New-Object Text.UTF8Encoding($false)))
    }

    Copy-Item -LiteralPath (Resolve-Path -LiteralPath $ThemeFile).Path -Destination (Join-Path $SourceDir 'src\stremio_app\themes.js') -Force
    Push-Location $SourceDir
    try { Invoke-Native -FilePath 'cargo.exe' -Arguments @('build', '--release', '--target', 'x86_64-pc-windows-msvc') }
    finally { Pop-Location }

    $isccPath = $null
    $isccCommand = Get-Command ISCC.exe -ErrorAction SilentlyContinue
    if ($isccCommand) { $isccPath = $isccCommand.Source }
    if (-not $isccPath) {
        foreach ($candidate in @('C:\Program Files (x86)\Inno Setup 6\ISCC.exe','C:\Program Files\Inno Setup 6\ISCC.exe',(Join-Path $env:LOCALAPPDATA 'Programs\Inno Setup 6\ISCC.exe'))) {
            if (Test-Path -LiteralPath $candidate -PathType Leaf) { $isccPath = $candidate; break }
        }
    }
    if (-not $isccPath) { throw 'Inno Setup compiler was not found. Install JRSoftware.InnoSetup and rerun.' }
    $issFile = Join-Path $SourceDir 'setup\Stremio.iss'
    if (-not (Test-Path -LiteralPath $issFile -PathType Leaf)) { throw "Installer script was not found: $issFile" }
    $compilerDir = Split-Path -Parent $isccPath
    $originalIssLines = @(& git.exe -C $SourceDir show 'HEAD:setup/Stremio.iss')
    if ($LASTEXITCODE -ne 0 -or $originalIssLines.Count -eq 0) { throw 'Could not restore the original installer script from the local source checkout.' }
    $patchedIssLines = foreach ($line in $originalIssLines) {
        if ($line -match '^Name:\s*"[^"]+";\s*MessagesFile:\s*"compiler:Languages\\([^"]+)"') {
            $languageFile = Join-Path $compilerDir ('Languages\' + $Matches[1])
            if (Test-Path -LiteralPath $languageFile -PathType Leaf) { $line }
            else {
                Write-Host "Using English installer text because $($Matches[1]) is missing."
                $line -replace 'MessagesFile:\s*"compiler:Languages\\[^"]+"', 'MessagesFile: "compiler:Default.isl"'
            }
        } else { $line }
    }
    if (-not ($patchedIssLines | Where-Object { $_ -match 'MessagesFile: "compiler:Default\.isl"' })) { throw 'The English installer language is missing from Inno Setup.' }
    [IO.File]::WriteAllLines($issFile, [string[]]$patchedIssLines, (New-Object Text.UTF8Encoding($true)))
    Push-Location $SourceDir
    try { Invoke-Native -FilePath $isccPath -Arguments @('/Qp','setup\Stremio.iss') }
    finally {
        Pop-Location
        [IO.File]::WriteAllLines($issFile, [string[]]$originalIssLines, (New-Object Text.UTF8Encoding($true)))
    }

    $installer = Get-ChildItem -LiteralPath $SourceDir -Filter 'StremioSetup-v*_x64.exe' -File | Sort-Object LastWriteTime -Descending | Select-Object -First 1
    if (-not $installer) { throw 'The build finished but the Stremio installer was not created.' }
    New-Item -ItemType Directory -Path $InstallDir -Force | Out-Null
    $oldExe = Join-Path $InstallDir 'stremio-shell-ng.exe'
    if (Test-Path -LiteralPath $oldExe -PathType Leaf) {
        $backup = Join-Path $InstallDir 'stremio-shell-ng.original.exe'
        if (-not (Test-Path -LiteralPath $backup)) { Copy-Item -LiteralPath $oldExe -Destination $backup }
    }
    Get-Process -Name 'stremio*' -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
    $dirArg = '/DIR=' + [char]34 + $InstallDir + [char]34
    $arguments = @('/VERYSILENT','/SUPPRESSMSGBOXES','/NORESTART','/SP-',$dirArg)
    $install = Start-Process -FilePath $installer.FullName -ArgumentList $arguments -Wait -PassThru
    if ($install.ExitCode -ne 0) { throw "Stremio installer failed with exit code $($install.ExitCode)." }
    $installedExe = Join-Path $InstallDir 'stremio-shell-ng.exe'
    if (-not (Test-Path -LiteralPath $installedExe -PathType Leaf)) { throw "Installer completed but the app was not found at $installedExe" }
    Start-Process -FilePath $installedExe
    Write-Host 'Method 2 complete. The themed Stremio shell was installed and started.' -ForegroundColor Green
} catch {
    Write-Error ("Method 2 failed: " + $_.Exception.Message)
    exit 1
}
