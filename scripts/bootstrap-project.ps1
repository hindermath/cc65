# bootstrap-project.ps1 — Idempotenter Projekt-Bootstrap v1.0 (PowerShell)
# FR-009–016; Contract: bootstrap-project-cli.md

[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory)][string]$ProjectName,
    [string]$TargetWorkspace = $PWD.Path,
    [switch]$Preview,
    [switch]$Force,
    [switch]$NoAgents,
    [switch]$NoSpeckit,
    [switch]$NoRemote,
    [string]$Platform = 'github',
    [string]$GitLabUrl = 'https://gitlab.com',
    [ValidateSet('de','en')][string]$Lang = 'de'
)

$ScriptDir    = Split-Path -Parent $MyInvocation.MyCommand.Path
$TemplatesDir = Join-Path $ScriptDir 'templates'
$TargetWorkspace = $TargetWorkspace.TrimEnd([IO.Path]::DirectorySeparatorChar)
$TargetDir    = Join-Path $TargetWorkspace $ProjectName

$Step = 0
$TotalSteps = 22
$Skipped = 0
$PartialFail = $false
$gitlabHostname = ''
$gitlabUser = ''
$projectSlug = ''
$projectSlugChanged = $false
$summaryRepoUrl = ''
$summaryDisplayRepo = ''

function Render-Template {
    param([string]$Template, [string]$Output)
    $wsShort = $TargetWorkspace -replace [regex]::Escape($(if ($env:HOME) { $env:HOME } else { $env:USERPROFILE })), '~'
    (Get-Content $Template) `
        -replace '\{\{PROJECT_NAME\}\}', $ProjectName `
        -replace '\{\{WORKSPACE\}\}', $wsShort |
        Set-Content -Path $Output -Encoding UTF8
}

function Step-Start { param([string]$Desc)
    $script:Step++
    Write-Host ("[{0}/{1}] -> {2,-44}" -f $script:Step, $TotalSteps, $Desc) -NoNewline
}
function Step-Done  { param([string]$Note='')
    if ($Note) { Write-Host " ✓  $Note" } else { Write-Host " ✓" }
}
function Step-Skip  { param([string]$Why='already done')
    Write-Host " (skip: $Why)"; $script:Skipped++
}
function Step-Warn  { param([string]$Msg)
    Write-Host " WARN: $Msg"; $script:PartialFail = $true
}

function ConvertTo-GitLabSlug([string]$Name) {
    $Name.ToLower() -replace '[^a-z0-9]', '-' -replace '-+', '-' -replace '^-|-$', ''
}

function Convert-RemoteUrlToRepoUrl([string]$RemoteUrl) {
    if ($RemoteUrl -like 'https://*') {
        return ($RemoteUrl -replace '\.git$', '')
    }
    if ($RemoteUrl -match '^git@([^:]+):(.+)$') {
        return ('https://' + $Matches[1] + '/' + ($Matches[2] -replace '\.git$', ''))
    }
    if ($RemoteUrl -match '^ssh://git@([^/]+)/(.+)$') {
        return ('https://' + $Matches[1] + '/' + ($Matches[2] -replace '\.git$', ''))
    }
    return ($RemoteUrl -replace '\.git$', '')
}

function Get-RepoNameFromRemoteUrl([string]$RemoteUrl) {
    $repoUrl = Convert-RemoteUrlToRepoUrl $RemoteUrl
    return [IO.Path]::GetFileName($repoUrl)
}

if ($Platform -notin @('github', 'gitlab')) {
    Write-Error "Fehler: Ungültige Plattform '$Platform'. Gültige Werte: github, gitlab.`nError: Invalid platform '$Platform'. Valid values: github, gitlab."
    exit 2
}

if ($Platform -eq 'gitlab') {
    if (-not $GitLabUrl.StartsWith('https://')) {
        Write-Error "Fehler: -GitLabUrl muss mit 'https://' beginnen.`nError: -GitLabUrl must start with 'https://'."
        exit 2
    }
    $gitlabHostname = ($GitLabUrl -replace '^https://', '').TrimEnd('/')
    $projectSlug = ConvertTo-GitLabSlug $ProjectName
    $projectSlugChanged = $projectSlug -ne $ProjectName

    if (-not $NoRemote) {
        if (-not (Get-Command glab -ErrorAction SilentlyContinue)) {
            Write-Error "Fehler: glab (GitLab CLI) ist nicht installiert.`n  macOS/Linux: brew install glab`n  Windows: winget install GLabCLI.GlabCLI`nError: glab (GitLab CLI) is not installed."
            exit 2
        }

        $env:GITLAB_HOST = $gitlabHostname
        & glab auth status 2>$null | Out-Null
        $authExitCode = $LASTEXITCODE
        $env:GITLAB_HOST = $null
        if ($authExitCode -ne 0) {
            Write-Error "Fehler: Nicht bei GitLab ($gitlabHostname) authentifiziert. Bitte 'glab auth login' ausführen.`nError: Not authenticated with GitLab ($gitlabHostname). Please run 'glab auth login'."
            exit 2
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
            exit 2
        }
    }
}

# ─── Preview Mode ────────────────────────────────────────────────────────────
if ($Preview) {
    Write-Host "[PREVIEW] Folgende Aktionen wuerden ausgefuehrt:"
    $previewActions = [System.Collections.Generic.List[object[]]]::new()
    $null = $previewActions.Add(@('CREATE', $TargetDir))
    $null = $previewActions.Add(@('EXEC', "git init $TargetDir"))
    $null = $previewActions.Add(@('CREATE', "$TargetDir/AGENTS.md", 'aus AGENTS.md.tmpl'))
    $null = $previewActions.Add(@('CREATE', "$TargetDir/CLAUDE.md", 'aus CLAUDE.md.tmpl'))
    $null = $previewActions.Add(@('CREATE', "$TargetDir/GEMINI.md", 'aus GEMINI.md.tmpl'))
    $null = $previewActions.Add(@('CREATE', "$TargetDir/.github/copilot-instructions.md", 'aus copilot-instructions.tmpl'))
    $null = $previewActions.Add(@('CREATE', "$TargetDir/README.md", 'aus readme-template.md / README.md.tmpl'))
    $null = $previewActions.Add(@('COPY', "$TargetDir/constitution.md", 'von ~/constitution.md'))
    $null = $previewActions.Add(@('CREATE', "$TargetDir/.github/workflows/homogeneity-check.yml"))
    $null = $previewActions.Add(@('CREATE', "$TargetDir/STATS.md"))
    $null = $previewActions.Add(@('CREATE', "$TargetDir/.gitignore", 'aus gitignore-project.tmpl'))
    $null = $previewActions.Add(@('COPY', "$TargetDir/scripts/", 'von ~/scripts/'))
    $null = $previewActions.Add(@('INSTALL', "$TargetDir/.git/hooks/pre-push"))
    $null = $previewActions.Add(@('EXEC', "git commit -m 'feat: initial project bootstrap'"))

    if ($NoRemote) {
        $null = $previewActions.Add(@('SKIP', 'Remote-Erstellung', '--no-remote'))
    } elseif ($Platform -eq 'github') {
        $null = $previewActions.Add(@('EXEC', 'gh repo create (privat)', 'optional'))
        $null = $previewActions.Add(@('EXEC', 'git push', 'optional'))
    } else {
        $null = $previewActions.Add(@('EXEC', 'glab repo create (privat)', 'optional'))
        $null = $previewActions.Add(@('EXEC', 'git remote add origin https://HOST/USER/REPO.git', 'optional'))
        $null = $previewActions.Add(@('EXEC', 'git push', 'optional'))
    }

    $null = $previewActions.Add(@('EXEC', "claude /init", 'optional'))
    $null = $previewActions.Add(@('PRINT', "Codex manuelle Anweisung"))
    $null = $previewActions.Add(@('PRINT', "Gemini manuelle Anweisung"))
    $null = $previewActions.Add(@('CHECK', "gh copilot --help", 'optional'))
    $null = $previewActions.Add(@('EXEC', "specify init --here --ai claude", 'optional'))
    $null = $previewActions.Add(@('EXEC', "init-stats.sh (Baseline)", 'STATS.md'))
    $null = $previewActions.Add(@('UPDATE', "$(if ($env:HOME) { $env:HOME } else { $env:USERPROFILE })/README.md"))

    $previewActions | ForEach-Object {
        $note = if ($_.Count -gt 2) { "($($_[2]))" } else { '' }
        $shortPath = $_[1] -replace [regex]::Escape($(if ($env:HOME) { $env:HOME } else { $env:USERPROFILE })), '~'
        Write-Host ("  {0,-8} {1,-50} {2}" -f $_[0], $shortPath, $note)
    }
    Write-Host "  [Keine Dateien wurden geschrieben]"
    exit 0
}

# ─── Pre-flight ───────────────────────────────────────────────────────────────
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Error "FATAL: git not found"
    exit 2
}
if (-not (Test-Path $TargetWorkspace)) {
    Write-Error "FATAL: target workspace does not exist: $TargetWorkspace"
    exit 2
}

# ─── Header ───────────────────────────────────────────────────────────────────
Write-Host ('=' * 50)
Write-Host "  bootstrap-project — Workspace Homogeneity Guardian"
Write-Host ('=' * 50)
Write-Host ""
Write-Host "Projekt:    $ProjectName"
$wsShort = $TargetWorkspace -replace [regex]::Escape($(if ($env:HOME) { $env:HOME } else { $env:USERPROFILE })), '~'
Write-Host "Workspace:  $wsShort"
$tdShort = $TargetDir -replace [regex]::Escape($(if ($env:HOME) { $env:HOME } else { $env:USERPROFILE })), '~'
Write-Host "Ziel:       $tdShort"
Write-Host ""

# ─── Steps ────────────────────────────────────────────────────────────────────

# 1. Create directory
Step-Start "Verzeichnis anlegen"
if (Test-Path $TargetDir) { Step-Skip "existiert bereits" }
else { New-Item -ItemType Directory -Path $TargetDir -Force | Out-Null; Step-Done }

# 2. git init
Step-Start "git init"
if (Test-Path (Join-Path $TargetDir '.git')) { Step-Skip ".git/ vorhanden" }
else { git init $TargetDir 2>$null | Out-Null; Step-Done }

# 2b. Lokale git-Einstellungen / Local git settings
Step-Start "Lokale git-Einstellungen / Local git settings"
if (Test-Path (Join-Path $TargetDir '.git')) {
    $autocrlf = if ($IsWindows) { 'true' } else { 'input' }
    git -C $TargetDir config --local core.autocrlf $autocrlf 2>$null | Out-Null
    Step-Done "Lokale git-Einstellungen gesetzt / Local git settings applied"
} else { Step-Skip "git-Repo noch nicht initialisiert / git repo not yet initialized" }

# 3. AGENTS.md
Step-Start "AGENTS.md erzeugen"
$f = Join-Path $TargetDir 'AGENTS.md'
if ((Test-Path $f) -and -not $Force) { Step-Skip "Datei existiert" }
elseif (Test-Path (Join-Path $TemplatesDir 'AGENTS.md.tmpl')) { Render-Template (Join-Path $TemplatesDir 'AGENTS.md.tmpl') $f; Step-Done }
else { Step-Warn "Template nicht gefunden: AGENTS.md.tmpl" }

# 4. CLAUDE.md
Step-Start "CLAUDE.md erzeugen"
$f = Join-Path $TargetDir 'CLAUDE.md'
if ((Test-Path $f) -and -not $Force) { Step-Skip "Datei existiert" }
elseif (Test-Path (Join-Path $TemplatesDir 'CLAUDE.md.tmpl')) { Render-Template (Join-Path $TemplatesDir 'CLAUDE.md.tmpl') $f; Step-Done }
else { Step-Warn "Template nicht gefunden: CLAUDE.md.tmpl" }

# 5. GEMINI.md
Step-Start "GEMINI.md erzeugen"
$f = Join-Path $TargetDir 'GEMINI.md'
if ((Test-Path $f) -and -not $Force) { Step-Skip "Datei existiert" }
elseif (Test-Path (Join-Path $TemplatesDir 'GEMINI.md.tmpl')) { Render-Template (Join-Path $TemplatesDir 'GEMINI.md.tmpl') $f; Step-Done }
else { Step-Warn "Template nicht gefunden: GEMINI.md.tmpl" }

# 6. copilot-instructions.md
Step-Start "copilot-instructions.md erzeugen"
$cpDir = Join-Path $TargetDir '.github'
$f = Join-Path $cpDir 'copilot-instructions.md'
if ((Test-Path $f) -and -not $Force) { Step-Skip "Datei existiert" }
else {
    New-Item -ItemType Directory -Path $cpDir -Force | Out-Null
    $tmpl = Join-Path $TemplatesDir 'copilot-instructions.tmpl'
    if (Test-Path $tmpl) { Render-Template $tmpl $f; Step-Done }
    else { Step-Warn "Template nicht gefunden: copilot-instructions.tmpl" }
}

# 7. README.md
Step-Start "README.md erzeugen"
$f = Join-Path $TargetDir 'README.md'
if ((Test-Path $f) -and -not $Force) { Step-Skip "Datei existiert" }
else {
    $readmeTmpl = Join-Path $TemplatesDir 'readme-template.md'
    if (-not (Test-Path $readmeTmpl)) { $readmeTmpl = Join-Path $TemplatesDir 'README.md.tmpl' }
    if (Test-Path $readmeTmpl) { Render-Template $readmeTmpl $f; Step-Done }
    else { Step-Warn "Template nicht gefunden: readme-template.md / README.md.tmpl" }
}

# 7b. constitution.md
Step-Start "constitution.md kopieren"
$homeConstitution = Join-Path $(if ($env:HOME) { $env:HOME } else { $env:USERPROFILE }) 'constitution.md'
$fc = Join-Path $TargetDir 'constitution.md'
if (-not (Test-Path $homeConstitution)) { Step-Warn "~/constitution.md fehlt — bitte sync-constitution.ps1 ausfuehren" }
elseif ((Test-Path $fc) -and -not $Force) { Step-Skip "Datei existiert" }
else { Copy-Item $homeConstitution $fc; Step-Done }

# 7c. homogeneity-check.yml
Step-Start "homogeneity-check.yml erzeugen"
$wfDir  = Join-Path $TargetDir '.github' | Join-Path -ChildPath 'workflows'
$wfFile = Join-Path $wfDir 'homogeneity-check.yml'
if ((Test-Path $wfFile) -and -not $Force) { Step-Skip "Datei existiert" }
else {
    New-Item -ItemType Directory -Path $wfDir -Force | Out-Null
    $constVer = 'v1.0.0'
    if (Test-Path $homeConstitution) {
        $firstLine = Get-Content $homeConstitution -TotalCount 1
        if ($firstLine -match '(v\d+\.\d+\.\d+)') { $constVer = $Matches[1] }
    }
    @"
name: Homogeneity Check

on:
  push:
    branches: ["**"]
  pull_request:
    branches: [main, master]

jobs:
  homogeneity:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Install ripgrep
        run: sudo apt-get install -y ripgrep
      - name: Run homogeneity check
        run: bash scripts/check-homogeneity.sh --json --exit-on-fail
        env:
          CONSTITUTION_VERSION: "$constVer"
"@ | Set-Content $wfFile -Encoding UTF8
    Step-Done
}

# 8. STATS.md
Step-Start "STATS.md (initial) erzeugen"
$f = Join-Path $TargetDir 'STATS.md'
if ((Test-Path $f) -and -not $Force) { Step-Skip "Datei existiert" }
else { "# STATS.md -- $ProjectName`n`nCompliance-Historie / Compliance History`n" | Set-Content $f -Encoding UTF8; Step-Done }

# 9. .gitignore
Step-Start ".gitignore erzeugen"
$f = Join-Path $TargetDir '.gitignore'
if ((Test-Path $f) -and -not $Force) { Step-Skip "Datei existiert" }
elseif (Test-Path (Join-Path $TemplatesDir 'gitignore-project.tmpl')) {
    Copy-Item (Join-Path $TemplatesDir 'gitignore-project.tmpl') $f
    Step-Done
} else { Step-Warn "Template nicht gefunden: gitignore-project.tmpl" }

# 10. Copy scripts/
Step-Start "scripts/ kopieren"
$scriptsTarget = Join-Path $TargetDir 'scripts'
if ((Test-Path $scriptsTarget) -and -not $Force) { Step-Skip "scripts/ vorhanden" }
elseif (Test-Path $ScriptDir) { Copy-Item $ScriptDir $scriptsTarget -Recurse -Force; Step-Done }
else { Step-Warn "~/scripts/ nicht gefunden" }

# 11. Install hook
Step-Start "pre-push Hook installieren"
$hookSrc = Join-Path $(if ($env:HOME) { $env:HOME } else { $env:USERPROFILE }) 'scripts/hooks/pre-push'
$hookDst = Join-Path $TargetDir '.git/hooks/pre-push'
if (Test-Path $hookSrc) {
    $hooksDir = Split-Path $hookDst
    if (-not (Test-Path $hooksDir)) { New-Item -ItemType Directory -Path $hooksDir -Force | Out-Null }
    if ((Test-Path $hookDst) -and -not $Force) {
        $srcH = (Get-FileHash -Algorithm SHA256 $hookSrc).Hash
        $dstH = (Get-FileHash -Algorithm SHA256 $hookDst).Hash
        if ($srcH -eq $dstH) { Step-Skip "Hook SHA-256 match" }
        else { Copy-Item $hookSrc $hookDst -Force; Step-Done "aktualisiert" }
    } else { Copy-Item $hookSrc $hookDst -Force; Step-Done }
} else { Step-Warn "~/scripts/hooks/pre-push nicht gefunden" }

# 12. Initial commit
Step-Start "Initialer git-Commit"
$logOutput = git -C $TargetDir log --oneline 2>$null
if ($logOutput) { Step-Skip "Commits vorhanden" }
else {
    git -C $TargetDir add -A 2>$null | Out-Null
    git -C $TargetDir commit -m "feat: initial project bootstrap -- $ProjectName" 2>$null | Out-Null
    Step-Done
}

# 13. Repo create
Step-Start "Repo erstellen (privat)"
$existingRemote = ''
if (-not $NoRemote) {
    $existingRemote = (& git -C $TargetDir remote get-url origin 2>$null | Out-String).Trim()
}
if ($NoRemote) { Step-Skip "-NoRemote" }
elseif ($existingRemote) {
    $summaryRepoUrl = Convert-RemoteUrlToRepoUrl $existingRemote
    $summaryDisplayRepo = Get-RepoNameFromRemoteUrl $existingRemote
    Step-Skip "Remote vorhanden"
}
elseif ($Platform -eq 'github' -and (Get-Command gh -ErrorAction SilentlyContinue)) {
    $repoName = $ProjectName.ToLower() -replace '\s+','-'
    & gh repo create $repoName --private --source $TargetDir --remote origin 2>$null | Out-Null
    if ($LASTEXITCODE -eq 0) {
        $ghUser = ((gh api user --jq '.login' 2>$null) | Out-String).Trim()
        $summaryRepoUrl = "https://github.com/$ghUser/$repoName"
        $summaryDisplayRepo = $repoName
        Step-Done $repoName
    } else { Step-Warn "gh repo create fehlgeschlagen" }
}
elseif ($Platform -eq 'gitlab') {
    $remoteUrl = "https://$gitlabHostname/$gitlabUser/$projectSlug.git"
    $env:GITLAB_HOST = $gitlabHostname
    & glab repo create $projectSlug --private 2>$null | Out-Null
    $env:GITLAB_HOST = $null
    if ($LASTEXITCODE -eq 0) {
        git -C $TargetDir remote add origin $remoteUrl 2>$null | Out-Null
        if ($LASTEXITCODE -eq 0) {
            $summaryRepoUrl = "$($GitLabUrl.TrimEnd('/'))/$gitlabUser/$projectSlug"
            $summaryDisplayRepo = $projectSlug
            Step-Done $projectSlug
        } else {
            Step-Warn "git remote add origin fehlgeschlagen / git remote add origin failed"
        }
    } else { Step-Warn "glab repo create fehlgeschlagen / glab repo create failed" }
} else { Step-Skip "gh nicht installiert" }

# 14. git push
Step-Start "git push"
$originRemote = ''
if (-not $NoRemote) {
    $originRemote = (& git -C $TargetDir remote get-url origin 2>$null | Out-String).Trim()
}
if ($NoRemote) { Step-Skip "-NoRemote" }
elseif (-not $originRemote) { Step-Skip "kein Remote konfiguriert" }
else {
    git -C $TargetDir push -u origin HEAD 2>$null | Out-Null
    if ($LASTEXITCODE -eq 0) { Step-Done } else { Step-Warn "git push fehlgeschlagen" }
}

# 15. Claude init
Step-Start "Claude init"
if ($NoAgents) { Step-Skip "-NoAgents" }
elseif ((Get-Content (Join-Path $TargetDir 'CLAUDE.md') -ErrorAction SilentlyContinue) -match 'claude-init-done') { Step-Skip "bereits initialisiert" }
elseif (Get-Command claude -ErrorAction SilentlyContinue) {
    Push-Location $TargetDir
    '/init' | claude 2>$null | Out-Null
    Pop-Location
    Add-Content (Join-Path $TargetDir 'CLAUDE.md') '<!-- claude-init-done -->'
    Step-Done
} else { Step-Warn "claude nicht installiert" }

# 16. Codex
Step-Start "Codex (interaktiv)"
Write-Host ""
Write-Host ("          -> Bitte manuell ausfuehren: cd $tdShort && codex")

# 17. Gemini
Step-Start "Gemini (interaktiv)"
Write-Host ""
Write-Host ("          -> Bitte manuell ausfuehren: cd $tdShort && agy")

# 18. Copilot check
Step-Start "Copilot verfuegbar pruefen"
if (Get-Command copilot -ErrorAction SilentlyContinue) {
    & copilot --version *> $null
    if ($LASTEXITCODE -eq 0) { Step-Done 'copilot verfuegbar' }
    else { Step-Skip 'copilot nicht nutzbar; Required-Host-Wartung ausfuehren' }
} else { Step-Skip 'copilot nicht installiert; Required-Host-Wartung ausfuehren' }

# 19. Spec-kit
Step-Start "Spec-kit installieren"
if ($NoSpeckit) { Step-Skip "-NoSpeckit" }
elseif ((Test-Path (Join-Path $TargetDir '.specify')) -and -not $Force) { Step-Skip ".specify/ vorhanden" }
elseif (Get-Command specify -ErrorAction SilentlyContinue) {
    Push-Location $TargetDir
    specify init --here --ai claude 2>$null | Out-Null
    Pop-Location
    if (Test-Path (Join-Path $TargetDir '.specify')) { Step-Done } else { Step-Warn "specify init kein .specify/ erstellt" }
} else {
    Step-Warn "specify nicht installiert"
    Write-Host "          -> uv tool install specify-cli --from git+https://github.com/github/spec-kit.git"
    Write-Host "          -> Dann: cd $tdShort && specify init --here --ai claude"
}

# 20. Compliance check + STATS baseline
Step-Start "Compliance-Check + STATS-Baseline"
$initStatsScript = Join-Path $ScriptDir 'init-stats.ps1'
$checkScript = Join-Path $ScriptDir 'check-homogeneity.sh'
if (Test-Path $initStatsScript) {
    & $initStatsScript $TargetDir 2>$null | Out-Null
    Step-Done "STATS.md Baseline geschrieben"
} elseif (Test-Path $checkScript) {
    $score = (bash $checkScript --dry-run $TargetDir 2>$null | Select-String 'Overall:').Line -replace '.*(\d+) %.*','$1'
    Step-Done "Score: $score %"
} else { Step-Skip "check-homogeneity.sh nicht gefunden" }

# 21. Update ~/README.md
Step-Start "~/README.md aktualisieren"
$homeReadme = Join-Path $(if ($env:HOME) { $env:HOME } else { $env:USERPROFILE }) 'README.md'
if ((Get-Content $homeReadme -ErrorAction SilentlyContinue) -match $ProjectName) { Step-Skip "Eintrag vorhanden" }
elseif ((Test-Path $homeReadme) -and (Select-String -Path $homeReadme -Pattern '<!-- workspace-table-end -->')) {
    $content = Get-Content $homeReadme -Raw
    $repoCell = if ($summaryRepoUrl -and $summaryDisplayRepo) { "[$summaryDisplayRepo]($summaryRepoUrl)" } else { '—' }
    $row = "| ``$tdShort/`` | $repoCell | ``bootstrap-project`` |`n"
    $content = $content -replace '<!-- workspace-table-end -->', "${row}<!-- workspace-table-end -->"
    $content | Set-Content $homeReadme -Encoding UTF8
    Step-Done
} else { Step-Skip "README.md oder Marker nicht gefunden" }

# ─── Footer ───────────────────────────────────────────────────────────────────
Write-Host ""
Write-Host ('=' * 50)
if ($PartialFail) { Write-Host "  Bootstrap teilweise abgeschlossen (Warnungen vorhanden)" }
else { Write-Host "  Bootstrap abgeschlossen ✓" }
if ($Platform -eq 'gitlab' -and $projectSlugChanged) {
    Write-Host "  GitLab-Slug : $projectSlug (normalisiert von: $ProjectName)"
}
if ($summaryRepoUrl) {
    Write-Host "  Repo   : $summaryRepoUrl"
    Write-Host "  Clone  : git clone $summaryRepoUrl.git $TargetDir"
}
Write-Host "  $tdShort/ ist bereit."
Write-Host ""
Write-Host "  Naechste Schritte:"
Write-Host "  -> cd $tdShort"
Write-Host "  -> codex   (interaktive Initialisierung)"
Write-Host "  -> gemini  (interaktive Initialisierung)"
Write-Host "  -> specify init --here --ai gemini  (+ codex, copilot, opencode)"
Write-Host "  -> specify specify `"Feature-Name`""
Write-Host ('=' * 50)

if ($PartialFail) { exit 1 }
exit 0
