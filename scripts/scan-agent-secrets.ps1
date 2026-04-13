#Requires -Version 7
<#
.SYNOPSIS
    Prüft git-getrackte Dateien auf Secret-Muster.
.DESCRIPTION
    Scannt ausschließlich Dateien, die 'git ls-files' kennt (.gitignore wird respektiert).
    Kann manuell oder als Bestandteil eines CI-Checks aufgerufen werden.

    Verwendung:
        pwsh scripts/scan-agent-secrets.ps1
        pwsh scripts/scan-agent-secrets.ps1 -FailOnHigh
        pwsh scripts/scan-agent-secrets.ps1 -Verbose
.PARAMETER FailOnHigh
    Beendet das Skript mit Exit-Code 2, wenn HIGH-Befunde vorliegen (für CI / pre-push).
.PARAMETER WorkspaceRoot
    Wurzelverzeichnis des Repositories. Standard: Verzeichnis dieses Skripts/../
#>
[CmdletBinding()]
param(
    [switch] $FailOnHigh,
    [string] $WorkspaceRoot = ''
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# --- Konfiguration / Configuration ---------------------------------------------------

$SecretNamePatterns = @(
    'auth\.json',
    '\.env(\.[^.]+)?$',
    '.*(secret|credential|creds).*\.(json|yaml|yml|xml|ini|cfg|conf|toml)$',
    '.*id_rsa.*',
    '\.(pem|key|p12|pfx)$'
)

$SecretContentPatterns = @(
    'id_token\s*[:=]',
    'access_token\s*[:=]',
    'refresh_token\s*[:=]',
    'api[_-]?key\s*[:=]',
    'client[_-]?secret\s*[:=]',
    'password\s*=',
    'authorization:\s*bearer',
    'bearer\s+[A-Za-z0-9\-._~+/]+=*',
    'sk-[A-Za-z0-9]{20,}',
    'ghp_[A-Za-z0-9]{20,}',
    'github_pat_[A-Za-z0-9_]{20,}',
    'AIza[0-9A-Za-z_-]{20,}',
    'AKIA[0-9A-Z]{16}',
    '-----BEGIN (RSA|OPENSSH|EC|DSA) PRIVATE KEY-----'
)

# --- Repository-Root ermitteln -------------------------------------------------------

$root = if ($WorkspaceRoot) {
    Resolve-Path $WorkspaceRoot
} else {
    Resolve-Path (Join-Path $PSScriptRoot '..')
}
$rootPath = $root.ProviderPath

Write-Verbose "Repository-Root: $rootPath"

# --- Nur git-getrackte Dateien laden -------------------------------------------------

$trackedRelative = & git -C $rootPath ls-files
if (-not $trackedRelative) {
    Write-Host 'Keine git-getrackten Dateien gefunden. Scan übersprungen.' -ForegroundColor Yellow
    exit 0
}

$trackedFiles = $trackedRelative | ForEach-Object { Join-Path $rootPath $_ }
Write-Verbose "$($trackedFiles.Count) getrackte Datei(en) werden geprüft."

# --- Scan: Dateinamen ----------------------------------------------------------------

$nameHits = $trackedFiles | Where-Object {
    $relative = [IO.Path]::GetRelativePath($rootPath, $_)
    if ($relative -like '.github/workflows/*') {
        return $false
    }
    $name = Split-Path $_ -Leaf
    $SecretNamePatterns | Where-Object { $name -match $_ }
}

# --- Scan: Dateiinhalte (Select-String) ----------------------------------------------

$contentHits = $trackedFiles |
    Where-Object { Test-Path $_ -PathType Leaf } |
    Select-String -Pattern $SecretContentPatterns -List |
    Select-Object -ExpandProperty Path -Unique

# --- Ergebnis ausgeben ---------------------------------------------------------------

$foundHigh = $false

if ($nameHits) {
    $foundHigh = $true
    Write-Host 'HIGH  Secret-ähnliche Dateinamen:' -ForegroundColor Red
    $nameHits | ForEach-Object { Write-Host "      $_" -ForegroundColor Red }
}

if ($contentHits) {
    $foundHigh = $true
    Write-Host 'HIGH  Secret-Muster im Dateiinhalt:' -ForegroundColor Red
    $contentHits | ForEach-Object { Write-Host "      $_" -ForegroundColor Red }
}

if (-not $foundHigh) {
    Write-Host 'OK    Keine Secrets in git-getrackten Dateien gefunden.' -ForegroundColor Green
}

# --- Exit-Code für CI / pre-push -----------------------------------------------------

if ($FailOnHigh -and $foundHigh) {
    Write-Host ''
    Write-Host '╔══════════════════════════════════════════════════════════════╗' -ForegroundColor Red
    Write-Host '║  PUSH ABGEBROCHEN: Mögliche Secrets in getrackten Dateien!  ║' -ForegroundColor Red
    Write-Host '║  Bitte die markierten Dateien bereinigen und erneut pushen.  ║' -ForegroundColor Red
    Write-Host '╚══════════════════════════════════════════════════════════════╝' -ForegroundColor Red
    exit 2
}
