#Requires -Version 7
# migrate-workspace.ps1 — Workspace Homogeneity Migration v1.0 (PowerShell)
# FR-REV-A01–A06; Contract: migrate-workspace-cli.md
#
# Usage: pwsh scripts/migrate-workspace.ps1 [-WorkspaceName <string>] [-WhatIf] [-Force]
# Exit codes: 0=success, 1=partial fail, 2=critical error
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

[CmdletBinding(SupportsShouldProcess)]
param(
    [string]$WorkspaceName = '',
    [switch]$WhatIf,
    [switch]$Force
)

$ScriptDir    = Split-Path -Parent $MyInvocation.MyCommand.Path
$TemplatesDir = Join-Path $ScriptDir 'templates'
$HomeDir      = $(if ($env:HOME) { $env:HOME } else { $env:USERPROFILE })

# ─── Prerequisites ────────────────────────────────────────────────────────────

foreach ($tmpl in @('a11y-section.md', 'speckit-workflow-section.md', 'azubis-section.md')) {
    if (-not (Test-Path (Join-Path $TemplatesDir $tmpl))) {
        Write-Error "ERROR: template not found: scripts/templates/$tmpl"
        exit 1
    }
}

$constitutionFile = Join-Path $HomeDir 'constitution.md'
$constitutionVersion = 'v1.0.0'
if (Test-Path $constitutionFile) {
    $vLine = Get-Content $constitutionFile | Where-Object { $_ -match '^# Constitution v' } | Select-Object -First 1
    if ($vLine -match 'v[\d.]+') { $constitutionVersion = $Matches[0] }
}

# ─── homogeneity-check.yml ────────────────────────────────────────────────────

$WorkflowYml = @'
name: Homogeneity Check

on:
  push:
  pull_request:

jobs:
  check:
    name: Homogeneity Check (${{ matrix.os }})
    runs-on: ${{ matrix.os }}
    timeout-minutes: 10

    strategy:
      matrix:
        os: [ubuntu-22.04, macos-14, windows-latest]

    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Install ripgrep (Ubuntu)
        if: runner.os == 'Linux'
        run: sudo apt-get install -y ripgrep

      - name: Install ripgrep (macOS)
        if: runner.os == 'macOS'
        run: brew install ripgrep

      - name: Install ripgrep (Windows)
        if: runner.os == 'Windows'
        run: choco install ripgrep -y

      - name: Run Homogeneity Check (Bash)
        if: runner.os != 'Windows'
        run: bash scripts/check-homogeneity.sh $(basename "$GITHUB_WORKSPACE")

      - name: Run Homogeneity Check (PowerShell)
        if: runner.os == 'Windows'
        shell: pwsh
        run: pwsh scripts/check-homogeneity.ps1 -WorkspaceName (Split-Path $env:GITHUB_WORKSPACE -Leaf)
'@

function Write-WorkflowYml {
    param([string]$TargetDir)
    $ymlFile = Join-Path $TargetDir '.github/workflows/homogeneity-check.yml'
    if (Test-Path $ymlFile) {
        Write-Host "  INFO: homogeneity-check.yml already present — skip"
        return $false
    }
    if ($WhatIf) {
        Write-Host "  WOULD CREATE: $($ymlFile -replace [regex]::Escape($HomeDir), '~')"
        return $true
    }
    $dir = Split-Path $ymlFile -Parent
    New-Item -ItemType Directory -Path $dir -Force | Out-Null
    $WorkflowYml | Set-Content -Path $ymlFile
    Write-Host "  CREATED: $($ymlFile -replace [regex]::Escape($HomeDir), '~')"
    return $true
}

function Write-Editorconfig {
    param([string]$TargetDir)
    $ecFile = Join-Path $TargetDir '.editorconfig'
    if (Test-Path $ecFile) {
        Write-Host "  INFO: .editorconfig already present — skip"
        return $false
    }
    $slnFiles = Get-ChildItem -Path $TargetDir -Filter '*.sln' -Depth 0 -ErrorAction SilentlyContinue
    if ($slnFiles.Count -eq 0) { return $false }
    if ($WhatIf) {
        Write-Host "  WOULD CREATE: $($ecFile -replace [regex]::Escape($HomeDir), '~')"
        return $true
    }
    @"
root = true

[*]
charset = utf-8
end_of_line = crlf
indent_style = space
indent_size = 4
trim_trailing_whitespace = true
insert_final_newline = true

[*.cs]
indent_size = 4

[*.md]
trim_trailing_whitespace = false
indent_size = 2

[*.{yml,yaml,json}]
indent_size = 2
"@ | Set-Content -Path $ecFile
    Write-Host "  CREATED: $($ecFile -replace [regex]::Escape($HomeDir), '~')"
    return $true
}

function Add-EnPlaceholder {
    param([string]$File, [string]$Label)
    if (-not (Test-Path $File)) { return $false }
    $content = Get-Content $File -Raw -ErrorAction SilentlyContinue
    if ($content -match '<!-- EN:') {
        Write-Host "  INFO: EN block already present — skip ($($File -replace [regex]::Escape($HomeDir), '~'))"
        return $false
    }
    if ($WhatIf) {
        Write-Host "  WOULD APPEND: EN placeholder to $($File -replace [regex]::Escape($HomeDir), '~')"
        return $true
    }
    $placeholder = "`n<!-- EN: $Label placeholder`n[DE-Zusammenfassung: Inhalt dieser Datei auf Deutsch]`n-->"
    Add-Content -Path $File -Value $placeholder
    Write-Host "  APPENDED: EN placeholder to $($File -replace [regex]::Escape($HomeDir), '~')"
    return $true
}

function Add-ReadmeSection {
    param([string]$Readme, [string]$SectionFile, [string]$HeadingPattern)
    if (-not (Test-Path $Readme)) { return $false }
    $content = Get-Content $Readme -Raw -ErrorAction SilentlyContinue
    if ($content -match "(?im)$HeadingPattern") {
        Write-Host "  INFO: section already present — skip ($(Split-Path $SectionFile -Leaf) in $(Split-Path $Readme -Leaf))"
        return $false
    }
    if ($WhatIf) {
        Write-Host "  WOULD APPEND: $(Split-Path $SectionFile -Leaf) to $($Readme -replace [regex]::Escape($HomeDir), '~')"
        return $true
    }
    Add-Content -Path $Readme -Value "`n"
    Get-Content $SectionFile | Add-Content -Path $Readme
    Write-Host "  APPENDED: $(Split-Path $SectionFile -Leaf) to $($Readme -replace [regex]::Escape($HomeDir), '~')"
    return $true
}

function Install-HookIfNeeded {
    param([string]$TargetDir)
    $hookSrc = Join-Path $HomeDir 'scripts/hooks/pre-push'
    $hookDst = Join-Path $TargetDir '.git/hooks/pre-push'
    if (-not (Test-Path (Join-Path $TargetDir '.git'))) { return $false }
    if (-not (Test-Path $hookSrc)) { return $false }
    if (Test-Path $hookDst) {
        Write-Host "  INFO: pre-push hook already installed — skip ($($TargetDir -replace [regex]::Escape($HomeDir), '~'))"
        return $false
    }
    if ($WhatIf) {
        Write-Host "  WOULD INSTALL: pre-push hook in $($TargetDir -replace [regex]::Escape($HomeDir), '~')"
        return $true
    }
    $hooksDir = Join-Path $TargetDir '.git/hooks'
    New-Item -ItemType Directory -Path $hooksDir -Force | Out-Null
    Copy-Item $hookSrc $hookDst
    Write-Host "  INSTALLED: pre-push hook in $($TargetDir -replace [regex]::Escape($HomeDir), '~')"
    return $true
}

# ─── Migrate Single Workspace ────────────────────────────────────────────────

$PartialFail = $false

function Migrate-Workspace {
    param([string]$WsDir)
    $wsName = Split-Path $WsDir -Leaf
    Write-Host "Migriere: $($WsDir -replace [regex]::Escape($HomeDir), '~')"

    $changed = $false

    foreach ($agentFile in @('README.md','AGENTS.md','CLAUDE.md','GEMINI.md','constitution.md')) {
        $fullPath = Join-Path $WsDir $agentFile
        if (Test-Path $fullPath) {
            if (Add-EnPlaceholder -File $fullPath -Label $agentFile) { $changed = $true }
        }
    }

    $copilotFile = Join-Path $WsDir '.github/copilot-instructions.md'
    if (Test-Path $copilotFile) {
        if (Add-EnPlaceholder -File $copilotFile -Label 'copilot-instructions.md') { $changed = $true }
    }

    $readme = Join-Path $WsDir 'README.md'
    if (Add-ReadmeSection -Readme $readme -SectionFile (Join-Path $TemplatesDir 'a11y-section.md') -HeadingPattern '^## .*Barrierefreiheit') { $changed = $true }
    if (Add-ReadmeSection -Readme $readme -SectionFile (Join-Path $TemplatesDir 'speckit-workflow-section.md') -HeadingPattern '^## .*Spec-kit') { $changed = $true }
    if (Add-ReadmeSection -Readme $readme -SectionFile (Join-Path $TemplatesDir 'azubis-section.md') -HeadingPattern '^## .*Azubis') { $changed = $true }

    if (Write-WorkflowYml -TargetDir $WsDir) { $changed = $true }

    # Level-2 projects
    Get-ChildItem -Path $WsDir -Directory -ErrorAction SilentlyContinue | Sort-Object Name | ForEach-Object {
        $projDir = $_.FullName
        if (-not (Test-Path (Join-Path $projDir '.git'))) { return }
        Write-Host "  Level-2: $(Split-Path $projDir -Leaf)/"
        if (Write-WorkflowYml -TargetDir $projDir) { $changed = $true }
        if (Write-Editorconfig -TargetDir $projDir) { $changed = $true }
        if (Install-HookIfNeeded -TargetDir $projDir) { $changed = $true }
    }

    if (-not $changed) {
        Write-Host "  INFO: already compliant — nothing to do"
        return
    }

    if ($WhatIf) {
        Write-Host "  [WhatIf: no changes written]"
        return
    }

    # Git commit
    $status = & git -C $WsDir status --porcelain 2>$null
    if ($status) {
        & git -C $WsDir add -A 2>$null
        & git -C $WsDir commit -m "chore: migrate $wsName to homogeneity baseline $constitutionVersion`n`nCo-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>" 2>$null | Out-Null
        Write-Host "  COMMITTED: migrate $wsName to homogeneity baseline $constitutionVersion"
    }

    Write-Host ""
}

# ─── Build Workspace List ─────────────────────────────────────────────────────

$workspaces = @()
if ($WorkspaceName) {
    $wsDir = Join-Path $HomeDir $WorkspaceName
    if (-not (Test-Path $wsDir)) {
        Write-Error "ERROR: Workspace nicht gefunden: $wsDir"
        exit 2
    }
    $workspaces = @($wsDir)
} else {
    $workspaces = Get-ChildItem -Path $HomeDir -Directory -ErrorAction SilentlyContinue |
        Where-Object { Test-Path (Join-Path $_.FullName '.git') } |
        Sort-Object Name |
        ForEach-Object { $_.FullName }
}

if ($workspaces.Count -eq 0) {
    Write-Host "Keine Level-1-Workspaces gefunden."
    exit 0
}

# ─── Preview ─────────────────────────────────────────────────────────────────

Write-Host "Workspace Homogeneity Migration"
Write-Host "Constitution: $constitutionVersion"
Write-Host ('=' * 50)
Write-Host ""
Write-Host "Betroffene Workspaces / Affected workspaces:"
foreach ($ws in $workspaces) {
    Write-Host "  -> $($ws -replace [regex]::Escape($HomeDir), '~')"
}
Write-Host ""

if ($WhatIf) {
    Write-Host "[WhatIf] Vorschau / Preview:"
    foreach ($ws in $workspaces) { Migrate-Workspace -WsDir $ws }
    exit 0
}

# ─── Prompt ──────────────────────────────────────────────────────────────────

if (-not $Force) {
    $answer = Read-Host "Proceed? [y/N]"
    if ($answer -notmatch '^[jJyY]') {
        Write-Host "Abgebrochen."
        exit 0
    }
}

# ─── Execute Migration ────────────────────────────────────────────────────────

foreach ($ws in $workspaces) {
    try {
        Migrate-Workspace -WsDir $ws
    } catch {
        Write-Warning "Migration fehlgeschlagen für $ws`: $_"
        $PartialFail = $true
    }
}

# ─── Post-Migration: init-stats ───────────────────────────────────────────────

$initStatsScript = Join-Path $ScriptDir 'init-stats.ps1'
if (Test-Path $initStatsScript) {
    Write-Host "Starte init-stats.ps1..."
    try { & pwsh $initStatsScript 2>$null } catch { }
}

Write-Host ""
Write-Host ('=' * 50)
if ($PartialFail) {
    Write-Host "Migration teilweise abgeschlossen (Warnungen vorhanden)"
    exit 1
}
Write-Host "Migration abgeschlossen"
exit 0
