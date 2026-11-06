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
        if (-not (Get-Command winget.exe -ErrorAction SilentlyContinue)) { throw 'winget is unavailable. Install Git, Rust (rustup), Visual Studio 2022 Build Tools with the C++ workload, and Inno Setup, then rerun.' }
        $packages = @(
            @{ Id = 'Git.Git'; Name = 'Git' },
            @{ Id = 'Rustlang.Rustup'; Name = 'Rustup' },
            @{ Id = 'Microsoft.VisualStudio.2022.BuildTools'; Name = 'Visual Studio 2022 Build Tools' },
            @{ Id = 'JRSoftware.InnoSetup'; Name = 'Inno Setup' }
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
        $innoPaths = @('C:\Program Files (x86)\Inno Setup 6\ISCC.exe','C:\Program Files\Inno Setup 6\ISCC.exe',(Join-Path $env:LOCALAPPDATA 'Programs\Inno Setup 6\ISCC.exe'))
        if (-not (Get-Command ISCC.exe -ErrorAction SilentlyContinue) -and -not ($innoPaths | Where-Object { Test-Path -LiteralPath $_ -PathType Leaf })) {
            Write-Host 'Inno Setup was listed by winget but its compiler is missing. Repairing the install...'
            Invoke-Native -FilePath 'winget.exe' -Arguments @('install','--id','JRSoftware.InnoSetup','--exact','--force','--accept-package-agreements','--accept-source-agreements')
        }
    }
    $env:Path = [Environment]::GetEnvironmentVariable('Path', 'Machine') + ';' + [Environment]::GetEnvironmentVariable('Path', 'User') + ';' + (Join-Path $HOME '.cargo\bin')
    foreach ($tool in @('git.exe','cargo.exe')) {
        if (-not (Get-Command $tool -ErrorAction SilentlyContinue)) { throw "$tool was not found. Close and reopen PowerShell after installing the build tools, then rerun." }
    }
    if (Get-Command rustup.exe -ErrorAction SilentlyContinue) { Invoke-Native -FilePath 'rustup.exe' -Arguments @('default', 'stable') }

    $updater = Join-Path $PSScriptRoot 'update-stremio.ps1'
    if (-not (Test-Path -LiteralPath $updater -PathType Leaf)) { throw 'Keep setup-build-pc.ps1 and update-stremio.ps1 in the same folder.' }
    $updateArgs = @{ SourceDir = $SourceDir; InstallDir = $InstallDir }
    if ($ThemeFile) { $updateArgs.ThemeFile = $ThemeFile }
    & $updater @updateArgs
} catch {
    Write-Error ("Method 2 setup failed: " + $_.Exception.Message)
    exit 1
}
