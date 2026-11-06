[CmdletBinding()]
param(
    [string]$ThemeFile,
    [string]$SourceDir = (Join-Path $HOME 'stremio-shell-ng-method2'),
    [string]$InstallDir = (Join-Path $env:LOCALAPPDATA 'Programs\Stremio'),
    [switch]$SkipPrerequisiteInstall
)

$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'

function Invoke-Native {
    param([Parameter(Mandatory)][string]$FilePath, [Parameter(Mandatory)][string[]]$Arguments)
    & $FilePath @Arguments
    if ($LASTEXITCODE -ne 0) { throw "$FilePath failed with exit code $LASTEXITCODE." }
}

function Resolve-ThemeFile {
    param([string]$RequestedPath)
    if ($RequestedPath) {
        if (-not (Test-Path -LiteralPath $RequestedPath -PathType Leaf)) { throw "Theme file not found: $RequestedPath" }
        return (Resolve-Path -LiteralPath $RequestedPath).Path
    }
    $candidates = @(
        (Join-Path $PSScriptRoot 'themes(3).js'),
        (Join-Path $PSScriptRoot 'themes.js'),
        (Join-Path $HOME 'Downloads\themes(3).js'),
        (Join-Path $HOME 'Downloads\themes.js')
    )
    foreach ($candidate in $candidates) {
        if (Test-Path -LiteralPath $candidate -PathType Leaf) { return (Resolve-Path -LiteralPath $candidate).Path }
    }
    Add-Type -AssemblyName System.Windows.Forms
    $dialog = New-Object System.Windows.Forms.OpenFileDialog
    $dialog.Title = 'Select your Stremio themes JavaScript file'
    $dialog.Filter = 'JavaScript files (*.js)|*.js|All files (*.*)|*.*'
    if ($dialog.ShowDialog() -ne [System.Windows.Forms.DialogResult]::OK) { throw 'No theme file was selected.' }
    return $dialog.FileName
}

function Ensure-Prerequisites {
    if ($SkipPrerequisiteInstall) { return }
    if (-not (Get-Command winget.exe -ErrorAction SilentlyContinue)) { throw 'winget is unavailable. Install Git, Rust (rustup), and Visual Studio 2022 Build Tools with the C++ workload, then rerun.' }
    $packages = @(
        @{ Id = 'Stremio.Stremio'; Name = 'Stremio' },
        @{ Id = 'Git.Git'; Name = 'Git' },
        @{ Id = 'Rustlang.Rustup'; Name = 'Rustup' },
        @{ Id = 'Microsoft.VisualStudio.2022.BuildTools'; Name = 'Visual Studio 2022 Build Tools' }
    )
    foreach ($package in $packages) {
        $installed = winget list --id $package.Id --exact --accept-source-agreements 2>$null | Out-String
        if ($LASTEXITCODE -ne 0 -or $installed -notmatch [regex]::Escape($package.Id)) {
            Write-Host "Installing $($package.Name)..."
            $args = @('install', '--id', $package.Id, '--exact', '--accept-package-agreements', '--accept-source-agreements')
            if ($package.Id -eq 'Microsoft.VisualStudio.2022.BuildTools') {
                $args += @('--override', '--wait --passive --add Microsoft.VisualStudio.Workload.VCTools --includeRecommended')
            }
            Invoke-Native -FilePath 'winget.exe' -Arguments $args
        }
    }
}

try {
    $theme = Resolve-ThemeFile -RequestedPath $ThemeFile
    if ((Get-Item -LiteralPath $theme).Length -eq 0) { throw "The theme file is empty: $theme" }

    Ensure-Prerequisites
    $env:Path = [Environment]::GetEnvironmentVariable('Path', 'Machine') + ';' + [Environment]::GetEnvironmentVariable('Path', 'User') + ';' + (Join-Path $HOME '.cargo\bin')
    if (-not (Get-Command git.exe -ErrorAction SilentlyContinue)) { throw 'Git was not found on PATH. Close and reopen PowerShell after installation, then rerun this script.' }
    if (-not (Get-Command cargo.exe -ErrorAction SilentlyContinue)) { throw 'Cargo was not found on PATH. Close and reopen PowerShell after installing Rust, then rerun this script.' }
    if (Get-Command rustup.exe -ErrorAction SilentlyContinue) { Invoke-Native -FilePath 'rustup.exe' -Arguments @('default', 'stable') }

    $SourceDir = [IO.Path]::GetFullPath($SourceDir)
    if (-not (Test-Path -LiteralPath $SourceDir)) {
        Write-Host "Cloning official Stremio shell source into $SourceDir..."
        $parent = Split-Path -Parent $SourceDir
        New-Item -ItemType Directory -Path $parent -Force | Out-Null
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

    $embeddedTheme = Join-Path $SourceDir 'src\stremio_app\themes.js'
    Copy-Item -LiteralPath $theme -Destination $embeddedTheme -Force
    Write-Host 'Building Stremio shell with the theme embedded in WebView2...'
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
    Write-Host 'Method 2 complete. Stremio was rebuilt with the selected theme and restarted.' -ForegroundColor Green
} catch {
    Write-Error ("Method 2 failed: " + $_.Exception.Message)
    exit 1
}
