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
        foreach ($candidate in @((Join-Path $PSScriptRoot 'themes(3).js'), (Join-Path $PSScriptRoot 'themes.js'), (Join-Path $HOME 'Downloads\themes(3).js'), (Join-Path $HOME 'Downloads\themes.js'))) {
            if (Test-Path -LiteralPath $candidate -PathType Leaf) { $ThemeFile = $candidate; break }
        }
    }
    if (-not $ThemeFile -or -not (Test-Path -LiteralPath $ThemeFile -PathType Leaf)) { throw 'Theme file not found. Place themes.js beside this script or in Downloads, or pass -ThemeFile "C:\path\to\themes.js".' }
    if ((Get-Item -LiteralPath $ThemeFile).Length -eq 0) { throw "The theme file is empty: $ThemeFile" }
    if (-not (Get-Command git.exe -ErrorAction SilentlyContinue)) { throw 'Git is required but was not found on PATH.' }
    if (-not (Get-Command cargo.exe -ErrorAction SilentlyContinue)) { throw 'Cargo is required but was not found on PATH. Install Rust (rustup) and reopen PowerShell.' }

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
        if ($matches.Count -ne 1) { throw 'Could not safely locate the WebView2 content-loading hook in upstream wevbiew.rs; no Rust source was changed.' }
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

    $builtExe = Join-Path $SourceDir 'target\x86_64-pc-windows-msvc\release\stremio-shell-ng.exe'
    if (-not (Test-Path -LiteralPath $builtExe -PathType Leaf)) { throw "Build succeeded but the expected executable was not produced: $builtExe" }
    $installedExe = Join-Path $InstallDir 'stremio-shell-ng.exe'
    if (-not (Test-Path -LiteralPath $InstallDir -PathType Container)) { throw "Stremio install folder not found: $InstallDir. Install Stremio or pass the correct -InstallDir." }

    Get-Process -Name 'stremio*' -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 1
    if (Test-Path -LiteralPath $installedExe -PathType Leaf) {
        $backup = Join-Path $InstallDir 'stremio-shell-ng.original.exe'
        if (-not (Test-Path -LiteralPath $backup)) { Copy-Item -LiteralPath $installedExe -Destination $backup }
    }
    Copy-Item -LiteralPath $builtExe -Destination $installedExe -Force
    Start-Process -FilePath $installedExe
    Write-Host 'Stremio rebuilt with the selected theme and restarted.' -ForegroundColor Green
} catch {
    Write-Error ("Method 2 failed: " + $_.Exception.Message)
    exit 1
}
