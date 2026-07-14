#Requires -Version 7
<#
.SYNOPSIS
    Richtet ein neues Projektverzeichnis als privates GitHub-Repo ein.
.DESCRIPTION
    Automatisiert: git init · .gitignore · Scripts kopieren · Repo erstellen · push · Hooks installieren

    Verwendung:
        pwsh ~/scripts/bootstrap-workspace.ps1 -WorkspaceName WebstormProjects
        pwsh ~/scripts/bootstrap-workspace.ps1 -WorkspaceName WebstormProjects -RepoName webstorm-baseline -Description "..."
        pwsh ~/scripts/bootstrap-workspace.ps1 -WorkspaceName WebstormProjects -WhatIf
        pwsh ~/scripts/bootstrap-workspace.ps1 -WorkspaceName WebstormProjects -Platform gitlab
.PARAMETER WorkspaceName
    Name des Projektverzeichnisses unterhalb des Home-Verzeichnisses.
.PARAMETER RepoName
    Name des GitHub-Repositories. Standard: <workspacename-lowercased>-baseline
.PARAMETER Description
    Beschreibung für das Remote-Repository.
#>
[CmdletBinding(SupportsShouldProcess)]
param(
    [switch] $Teardown,
    [string] $WorkspaceName = '',
    [string] $RepoName      = '',
    [string] $Description   = '',
    [string] $Platform      = 'github',
    [string] $GitLabUrl     = 'https://gitlab.com',
    [switch] $Backup,
    [switch] $KeepRemote,
    [switch] $Recursive,
    [switch] $Force,
    [switch] $Yes
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

if ($Teardown) {
    if (-not $WorkspaceName) {
        throw "Fehler: -WorkspaceName ist für -Teardown erforderlich / Error: -WorkspaceName is required for -Teardown"
    }

    $teardownPath = Join-Path $PSScriptRoot 'teardown-workspace.ps1'
    & pwsh -NoProfile -File $teardownPath `
        -WorkspaceName $WorkspaceName `
        -Backup:$Backup `
        -KeepRemote:$KeepRemote `
        -Recursive:$Recursive `
        -Force:$Force `
        -Yes:$Yes `
        -WhatIf:$WhatIfPreference
    exit $LASTEXITCODE
}

if (-not $WorkspaceName) {
    throw "Fehler: -WorkspaceName ist erforderlich / Error: -WorkspaceName is required"
}

if ($Platform -notin @('github', 'gitlab')) {
    throw "Fehler: Ungültige Plattform '$Platform'. Gültige Werte: github, gitlab.`nError: Invalid platform '$Platform'. Valid values: github, gitlab."
}

$gitlabHostname = ''
if ($Platform -eq 'gitlab') {
    if (-not $GitLabUrl.StartsWith('https://')) {
        throw "Fehler: -GitLabUrl muss mit 'https://' beginnen.`nError: -GitLabUrl must start with 'https://'."
    }
    $gitlabHostname = ($GitLabUrl -replace '^https://', '').TrimEnd('/')
}

function ConvertTo-NormalizedName([string]$Name) {
    $Name.ToLower() -replace '[^a-z0-9]', '-' -replace '-+', '-' -replace '^-|-$', ''
}

$homeDir       = $(if ($env:HOME) { $env:HOME } else { $env:USERPROFILE })
$workspaceDir  = Join-Path $homeDir $WorkspaceName
$scriptsSource = Join-Path $homeDir 'scripts'

if (-not $RepoName) {
    $RepoName = ($WorkspaceName -replace 'Projects$', '-baseline' -replace ' ', '-').ToLower()
}
if (-not $Description) {
    $Description = "Gemeinsame Workspace-Konfiguration für $WorkspaceName"
}

$ghUser = ''
$gitlabUser = ''
$repoSlug = $RepoName
$slugChanged = $false

if ($Platform -eq 'github') {
    if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
        Write-Error "Fehler: gh (GitHub CLI) ist nicht installiert.`nError: gh (GitHub CLI) is not installed."
    }

    $ghUser = ((gh api user --jq '.login' 2>$null) | Out-String).Trim()
    if (-not $ghUser) {
        Write-Error "Fehler: Konnte GitHub-Benutzername nicht ermitteln. Bitte 'gh auth login' ausführen.`nError: Could not retrieve GitHub username. Please run 'gh auth login'."
    }
} else {
    if (-not (Get-Command glab -ErrorAction SilentlyContinue)) {
        Write-Error "Fehler: glab (GitLab CLI) ist nicht installiert.`n  macOS/Linux: brew install glab`n  Windows: winget install GLabCLI.GlabCLI`nError: glab (GitLab CLI) is not installed."
    }

    $env:GITLAB_HOST = $gitlabHostname
    & glab auth status 2>$null | Out-Null
    $authExitCode = $LASTEXITCODE
    $env:GITLAB_HOST = $null
    if ($authExitCode -ne 0) {
        Write-Error "Fehler: Nicht bei GitLab ($gitlabHostname) authentifiziert. Bitte 'glab auth login' ausführen.`nError: Not authenticated with GitLab ($gitlabHostname). Please run 'glab auth login'."
    }

    $gitlabUserResponse = ((& glab api user --hostname $gitlabHostname 2>$null) | Out-String).Trim()
    $gitlabUser = ''
    if ($gitlabUserResponse) {
        try {
            $gitlabUser = ((($gitlabUserResponse | ConvertFrom-Json).username) | Out-String).Trim()
        } catch {
            $gitlabUser = ''
        }
    }
    if (-not $gitlabUser) {
        Write-Error "Fehler: GitLab-Benutzername konnte nicht ermittelt werden.`nError: Could not retrieve GitLab username."
    }

    $repoSlug = ConvertTo-NormalizedName $RepoName
    $slugChanged = $repoSlug -ne $RepoName
}

# --- Vorabprüfungen ------------------------------------------------------------

if (-not (Test-Path $workspaceDir -PathType Container)) {
    Write-Error "Verzeichnis '$workspaceDir' existiert nicht."
}
if (Test-Path (Join-Path $workspaceDir '.git') -PathType Container) {
    Write-Error "'$workspaceDir' ist bereits ein Git-Repository."
}
# --- Zusammenfassung -----------------------------------------------------------

Write-Host ''
Write-Host '╔══════════════════════════════════════════════════════════════════╗' -ForegroundColor Cyan
Write-Host '║  bootstrap-workspace – Neue Workspace-Einrichtung               ║' -ForegroundColor Cyan
Write-Host '╠══════════════════════════════════════════════════════════════════╣' -ForegroundColor Cyan
Write-Host "║  Verzeichnis : $($workspaceDir.PadRight(51))║" -ForegroundColor Cyan
Write-Host "║  Beschreibung: $($Description.Substring(0, [Math]::Min($Description.Length, 51)).PadRight(51))║" -ForegroundColor Cyan
if ($Platform -eq 'github') {
    Write-Host "║  GitHub-Repo : $("$ghUser/$RepoName (privat)".PadRight(51))║" -ForegroundColor Cyan
    Write-Host "║  Plattform   : $('GitHub (privat)'.PadRight(51))║" -ForegroundColor Cyan
} else {
    Write-Host "║  GitLab-Repo : $("$gitlabUser/$repoSlug (privat)".PadRight(51))║" -ForegroundColor Cyan
    Write-Host "║  Plattform   : $("GitLab — $GitLabUrl (privat)".PadRight(51))║" -ForegroundColor Cyan
    if ($slugChanged) {
        $slugLine = "$repoSlug (normalisiert von: $RepoName)"
        if ($slugLine.Length -gt 51) { $slugLine = $slugLine.Substring(0, 51) }
        Write-Host "║  GitLab-Slug : $($slugLine.PadRight(51))║" -ForegroundColor Cyan
    }
}
Write-Host '╚══════════════════════════════════════════════════════════════════╝' -ForegroundColor Cyan
Write-Host ''

# --- Sub-Repos ermitteln -------------------------------------------------------

Write-Host '→ Suche bestehende Sub-Repositories …'
$subRepos = Get-ChildItem -Path $workspaceDir -Directory -Recurse -Depth 1 |
    Where-Object { Test-Path (Join-Path $_.FullName '.git') -PathType Container } |
    Select-Object -ExpandProperty Name
$subRepos | ForEach-Object { Write-Host "    Gefunden: $_/" }

# --- .gitignore erstellen ------------------------------------------------------

Write-Host '→ Erstelle .gitignore …'
$gitignorePath = Join-Path $workspaceDir '.gitignore'
if ($PSCmdlet.ShouldProcess($gitignorePath, '.gitignore erstellen')) {
    $lines  = @('# Sub-Verzeichnisse mit eigenen Git-Repositories (automatisch erkannt)')
    $lines += $subRepos | ForEach-Object { "$_/" }
    $lines += @(
        '',
        '# macOS',
        '.DS_Store',
        '.AppleDouble',
        '.LSOverride',
        '',
        '# JetBrains IDEs',
        '.idea/',
        '*.iws',
        '*.iml',
        '',
        '# VS Code (lokale Einstellungen)',
        '.vscode/c_cpp_properties.json',
        '.vscode/settings.json',
        '',
        '# Build-Artefakte',
        'bin/',
        'obj/',
        'build/',
        'node_modules/'
    )
    $lines | Set-Content -Path $gitignorePath -Encoding UTF8
    Write-Host '    OK  .gitignore erstellt' -ForegroundColor Green
}

# --- Scripts kopieren ----------------------------------------------------------

Write-Host '→ Kopiere Scripts …'
$targetScripts = Join-Path $workspaceDir 'scripts'
$targetHooks   = Join-Path $targetScripts 'hooks'

if ($PSCmdlet.ShouldProcess($targetScripts, 'Scripts kopieren')) {
    New-Item -ItemType Directory -Path $targetScripts -Force | Out-Null
    New-Item -ItemType Directory -Path $targetHooks   -Force | Out-Null
    $filesToCopy = @(
        'scan-agent-secrets.sh',
        'scan-agent-secrets.ps1',
        'install-hooks.sh',
        'install-hooks.ps1'
    )
    foreach ($file in $filesToCopy) {
        Copy-Item (Join-Path $scriptsSource $file) $targetScripts -Force
    }
    Copy-Item (Join-Path $scriptsSource 'hooks' 'pre-push') $targetHooks -Force
    if ($IsLinux -or $IsMacOS) {
        Get-ChildItem $targetScripts -Filter '*.sh' | ForEach-Object { & chmod +x $_.FullName }
        & chmod +x (Join-Path $targetHooks 'pre-push')
    }
    Write-Host '    OK  Scripts kopiert' -ForegroundColor Green
}

# --- git init + commit ---------------------------------------------------------

Write-Host '→ Initialisiere Git-Repository …'
if ($PSCmdlet.ShouldProcess($workspaceDir, 'git init + commit')) {
    & git -C $workspaceDir init
    & git -C $workspaceDir add .gitignore scripts/
    $commitMsg = @"
chore: initiale Baseline-Konfiguration für $WorkspaceName

- .gitignore        – schließt Sub-Repos und Artefakte aus
- scripts/          – Secret-Scan, Hook-Installation (Bash + PowerShell)

Nach dem Clonen auf neuem Gerät:
  bash scripts/install-hooks.sh       (macOS/Linux)
  pwsh scripts/install-hooks.ps1      (Windows)

Co-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>
"@
    & git -C $workspaceDir commit -m $commitMsg
    Write-Host '    OK  Initialer Commit erstellt' -ForegroundColor Green
}

# --- GitHub-Repo erstellen und pushen ------------------------------------------

if ($Platform -eq 'github') {
    Write-Host "→ Erstelle privates GitHub-Repository '$RepoName' …"
    if ($PSCmdlet.ShouldProcess("github.com/$ghUser/$RepoName", 'gh repo create')) {
        & gh repo create $RepoName --private --description $Description `
            --source $workspaceDir --remote origin --push
        Write-Host '    OK  GitHub-Repo erstellt und gepusht' -ForegroundColor Green
    }
} else {
    $remoteUrl = "https://$gitlabHostname/$gitlabUser/$repoSlug.git"
    Write-Host "→ Erstelle privates GitLab-Repository '$repoSlug' …"
    if ($PSCmdlet.ShouldProcess("$GitLabUrl/$gitlabUser/$repoSlug", 'glab repo create + git remote add + git push')) {
        $env:GITLAB_HOST = $gitlabHostname
        & glab repo create $repoSlug --private --description $Description
        $env:GITLAB_HOST = $null
        Write-Host '    OK  GitLab-Repo erstellt' -ForegroundColor Green
        & git -C $workspaceDir remote add origin $remoteUrl
        & git -C $workspaceDir push -u origin HEAD
        Write-Host '    OK  Remote gesetzt und gepusht' -ForegroundColor Green
    }
}

# --- Hooks installieren --------------------------------------------------------

Write-Host '→ Installiere Git-Hooks …'
if ($PSCmdlet.ShouldProcess($workspaceDir, 'Hooks installieren')) {
    pwsh (Join-Path $targetScripts 'install-hooks.ps1')
    Write-Host '    OK  Hooks installiert' -ForegroundColor Green
}

# --- ~/README.md aktualisieren ------------------------------------------------

$homeReadme = Join-Path $homeDir 'README.md'
if ($Platform -eq 'github') {
    $repoUrl = "https://github.com/$ghUser/$RepoName"
    $displayRepo = $RepoName
} else {
    $repoUrl = "$($GitLabUrl.TrimEnd('/'))/$gitlabUser/$repoSlug"
    $displayRepo = $repoSlug
}
$newRow = "| ``~/$WorkspaceName/`` | [$displayRepo]($repoUrl) | ``bootstrap-workspace`` |"

if (Test-Path $homeReadme) {
    Write-Host '→ Aktualisiere ~/README.md …'
    $content = Get-Content $homeReadme -Raw
    if ($content -match "~/$WorkspaceName/") {
        Write-Host "    Eintrag für '$WorkspaceName' bereits vorhanden – übersprungen." -ForegroundColor Yellow
    } elseif ($PSCmdlet.ShouldProcess($homeReadme, 'Workspace-Tabelle aktualisieren')) {
        $updated = $content -replace '<!-- workspace-table-end -->', "$newRow`n<!-- workspace-table-end -->"
        Set-Content -Path $homeReadme -Value $updated -Encoding UTF8 -NoNewline
        Write-Host '    OK  ~/README.md aktualisiert' -ForegroundColor Green
    }
}

# --- home-baseline committen und pushen ----------------------------------------

$homeGit = Join-Path $homeDir '.git'
if (Test-Path $homeGit -PathType Container) {
    Write-Host '→ Committe Änderungen in home-baseline …'
    if ($PSCmdlet.ShouldProcess('home-baseline', 'commit + push')) {
        & git -C $homeDir add README.md
        $msg = @"
chore: $WorkspaceName in Workspace-Übersicht eingetragen

Automatisch durch bootstrap-workspace.ps1 hinzugefügt.

Co-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>
"@
        & git -C $homeDir commit -m $msg
        $hasRemote = $null -ne (& git -C $homeDir remote get-url origin 2>$null)
        if ($hasRemote) {
            & git -C $homeDir push
            Write-Host '    OK  home-baseline aktualisiert und gepusht' -ForegroundColor Green
        } else {
            Write-Host '    OK  home-baseline committed (kein Remote konfiguriert — Push übersprungen / no remote configured — push skipped)' -ForegroundColor Green
        }
    }
}



# --- Git Scope-Isolierung -------------------------------------------------------

Write-Host '→ Git Scope-Isolierung / Git Scope Isolation:'
$normalizedName = ConvertTo-NormalizedName $WorkspaceName
$gitconfigD = Join-Path $homeDir '.gitconfig.d'
$gitconfig  = Join-Path $homeDir '.gitconfig'

if (Test-Path $gitconfigD) {
    # core.autocrlf im lokalen .git/config setzen (Windows: true; macOS/Linux über .sh-Pendant)
    if ($PSCmdlet.ShouldProcess($workspaceDir, 'git config --local core.autocrlf')) {
        $autocrlf = if ($IsWindows) { 'true' } else { 'input' }
        & git -C $workspaceDir config --local core.autocrlf $autocrlf
    }

    # Idempotenz-Prüfung: includeIf-Block bereits vorhanden?
    $includeIfPattern = "gitdir:~/$WorkspaceName/"
    $alreadyPresent = (Get-Content $gitconfig -ErrorAction SilentlyContinue) |
        Select-String -SimpleMatch $includeIfPattern -Quiet

    if (-not $alreadyPresent) {
        if ($PSCmdlet.ShouldProcess($gitconfig, "includeIf für $WorkspaceName hinzufügen")) {
            $incRelPath = "~/.gitconfig.d/$normalizedName.inc"
            $block = "`n[includeIf `"gitdir:~/$WorkspaceName/`"]`n`tpath = $incRelPath"
            Add-Content -Path $gitconfig -Value $block -Encoding UTF8
        }
        Write-Host "  ✓ includeIf für $WorkspaceName / includeIf for $WorkspaceName eingetragen"
    } else {
        Write-Host "  → includeIf für $WorkspaceName bereits vorhanden — übersprungen / already present — skipped"
    }

    # .inc-Placeholder erstellen wenn nicht vorhanden
    $incFile = Join-Path $gitconfigD "$normalizedName.inc"
    if (-not (Test-Path $incFile)) {
        if ($PSCmdlet.ShouldProcess($incFile, '.inc Placeholder erstellen')) {
            @(
                "# $WorkspaceName workspace git configuration",
                '# [user]',
                '#   email = work@example.com'
            ) | Set-Content -Path $incFile -Encoding UTF8
        }
        Write-Host "  ✓ ~/.gitconfig.d/$normalizedName.inc erstellt / created"
    } else {
        Write-Host "  → ~/.gitconfig.d/$normalizedName.inc bereits vorhanden — übersprungen / already exists — skipped"
    }
} else {
    Write-Host "  → ~/.gitconfig.d/ nicht vorhanden — Scope-Isolierung übersprungen / not found — skipping scope isolation"
}

Write-Host ''
Write-Host '╔══════════════════════════════════════════════════════════════════╗' -ForegroundColor Green
Write-Host '║  Einrichtung abgeschlossen!                                      ║' -ForegroundColor Green
Write-Host '╚══════════════════════════════════════════════════════════════════╝' -ForegroundColor Green
Write-Host ''
if ($Platform -eq 'gitlab' -and $slugChanged) {
    Write-Host "  GitLab-Slug : $repoSlug (normalisiert von: $RepoName)"
}
Write-Host "  Repo  : $repoUrl"
Write-Host "  Clone : git clone $repoUrl.git ~/$WorkspaceName"
Write-Host "  Hooks : bash scripts/install-hooks.sh  (oder pwsh scripts/install-hooks.ps1)"
Write-Host ''
