#Requires -Version 7
# windows-test.ps1 — Sammelt System-Info und Testergebnisse auf Windows
# Ausgabe wird nach ~/home-baseline-tmp/windows-test-output.txt geschrieben
# und automatisch committet + gepusht.
#
# Verwendung: pwsh ~/home-baseline-tmp/scripts/windows-test.ps1
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$HomeDir   = $(if ($env:HOME) { $env:HOME } else { $env:USERPROFILE })
$RepoDir   = Join-Path $HomeDir 'home-baseline-tmp'
$OutFile   = Join-Path $RepoDir 'windows-test-output.txt'
$Date      = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
$Lines     = [System.Collections.Generic.List[string]]::new()

function Add-Line { param([string]$Text = '') $Lines.Add($Text); Write-Host $Text }

Add-Line "Windows Test Output - ${Date}"
Add-Line ""

# === System-Info ===
Add-Line "=== System-Info ==="
$os = Get-CimInstance Win32_OperatingSystem
Add-Line "OS:        $($os.Caption) $($os.Version)"
Add-Line "Arch:      $($env:PROCESSOR_ARCHITECTURE)"
Add-Line "Shell:     PowerShell $($PSVersionTable.PSVersion)"
Add-Line "Edition:   $($PSVersionTable.PSEdition)"
Add-Line ""

# === Paketmanager ===
Add-Line "=== Paketmanager ==="
foreach ($pm in @('winget', 'choco', 'scoop')) {
    if (Get-Command $pm -ErrorAction SilentlyContinue) {
        $ver = (& $pm --version 2>$null | Select-Object -First 1) -replace '\s+', ' '
        Add-Line "  OK  ${pm}: ${ver}"
    } else {
        Add-Line "  --- ${pm}: nicht installiert"
    }
}
Add-Line ""

# === Tools ===
Add-Line "=== Tools ==="
foreach ($cmd in @('git', 'gh', 'rg', 'node', 'uv', 'python', 'specify')) {
    if (Get-Command $cmd -ErrorAction SilentlyContinue) {
        Add-Line "  OK  ${cmd}"
    } else {
        Add-Line "  --- ${cmd}: fehlt"
    }
}
Add-Line ""

# === WSL ===
Add-Line "=== WSL ==="
try {
    $wslList = wsl --list --verbose 2>&1
    $wslList | ForEach-Object { Add-Line "  $_" }
} catch {
    Add-Line "  WSL nicht verfuegbar oder kein Distro installiert"
}
Add-Line ""

# === sync-home ===
Add-Line "=== sync-home ==="
$syncScript = Join-Path $RepoDir 'scripts\sync-home.ps1'
$syncOutput = pwsh -NoProfile -File $syncScript -NoPull 2>&1
$syncOutput | ForEach-Object { Add-Line "$_" }
Add-Line ""

# === check-homogeneity ===
Add-Line "=== check-homogeneity ==="
$checkScript = Join-Path $HomeDir 'scripts\check-homogeneity.ps1'
$checkOutput = pwsh -NoProfile -File $checkScript -TargetDir $HomeDir 2>&1
$checkOutput | ForEach-Object { Add-Line "$_" }

# Datei schreiben
$Lines | Set-Content -Path $OutFile -Encoding UTF8

# Committen und pushen
Set-Location $RepoDir
git pull --rebase --autostash origin main 2>&1 | ForEach-Object { Write-Host $_ }
git add windows-test-output.txt
git commit -m "test: Windows Test-Output (${Date})" -m "Co-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>"
git push origin HEAD:main
Add-Line "Gepusht."
