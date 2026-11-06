[CmdletBinding()]
param(
    [string]$ThemeFile,
    [string]$SourceDir = (Join-Path $HOME 'stremio-shell-ng-method2'),
    [string]$InstallDir = (Join-Path $env:LOCALAPPDATA 'Programs\Stremio'),
    [switch]$SkipPrerequisiteInstall
)
$ErrorActionPreference = 'Stop'

function Invoke-Native {
    param([Parameter(Mandatory)][string]$FilePath, [Parameter(Mandatory)][string[]]$Arguments)
    & $FilePath @Arguments
    if ($LASTEXITCODE -ne 0) { throw "$FilePath failed with exit code $LASTEXITCODE." }
}

try {
    if (-not $SkipPrerequisiteInstall) {
        if (-not (Get-Command winget.exe -ErrorAction SilentlyContinue)) { throw 'winget is unavailable. Install Git, Rust (rustup), and Visual Studio 2022 Build Tools with the C++ workload, then rerun.' }
        $packages = @(
            @{ Id = 'Stremio.Stremio'; Name = 'Stremio' },
            @{ Id = 'Git.Git'; Name = 'Git' },
            @{ Id = 'Rustlang.Rustup'; Name = 'Rustup' },
            @{ Id = 'Microsoft.VisualStudio.2022.BuildTools'; Name = 'Visual Studio 2022 Build Tools' }
        )
        foreach ($package in $packages) {
            $listed = winget list --id $package.Id --exact --accept-source-agreements 2>$null | Out-String
            if ($LASTEXITCODE -ne 0 -or $listed -notmatch [regex]::Escape($package.Id)) {
                Write-Host "Installing $($package.Name)..."
                $args = @('install', '--id', $package.Id, '--exact', '--accept-package-agreements', '--accept-source-agreements')
                if ($package.Id -eq 'Microsoft.VisualStudio.2022.BuildTools') {
                    $args += @('--override', '--wait --passive --add Microsoft.VisualStudio.Workload.VCTools --includeRecommended')
                }
                Invoke-Native -FilePath 'winget.exe' -Arguments $args
            }
        }
    }
    $env:Path = [Environment]::GetEnvironmentVariable('Path', 'Machine') + ';' + [Environment]::GetEnvironmentVariable('Path', 'User') + ';' + (Join-Path $HOME '.cargo\bin')
    if (-not (Get-Command git.exe -ErrorAction SilentlyContinue)) { throw 'Git was not found on PATH. Close and reopen PowerShell after installation, then rerun.' }
    if (-not (Get-Command cargo.exe -ErrorAction SilentlyContinue)) { throw 'Cargo was not found on PATH. Close and reopen PowerShell after installing Rust, then rerun.' }
    if (Get-Command rustup.exe -ErrorAction SilentlyContinue) { Invoke-Native -FilePath 'rustup.exe' -Arguments @('default', 'stable') }

    $updater = Join-Path $PSScriptRoot 'update-stremio.ps1'
    if (-not (Test-Path -LiteralPath $updater -PathType Leaf)) { throw "Put setup-build-pc.ps1 and update-stremio.ps1 in the same folder." }
    $args = @{ SourceDir = $SourceDir; InstallDir = $InstallDir }
    if ($ThemeFile) { $args.ThemeFile = $ThemeFile }
    & $updater @args
    if ($LASTEXITCODE -and $LASTEXITCODE -ne 0) { throw "The update script failed with exit code $LASTEXITCODE." }
} catch {
    Write-Error ("Method 2 setup failed: " + $_.Exception.Message)
    exit 1
}
