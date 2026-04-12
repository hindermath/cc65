# hg-scan.ps1 — 3-Ebenen-Traversal Engine (FR-001) — PowerShell
# Gibt pro qualifizierendem Verzeichnis PSObject mit Level, Path, Type aus

function Invoke-HgScan {
    param(
        [string]$TargetDir = $(if ($env:HOME) { $env:HOME } else { $env:USERPROFILE })
    )

    $TargetDir = $TargetDir.TrimEnd([IO.Path]::DirectorySeparatorChar)

    # Level 0
    [PSCustomObject]@{ Level = 0; Path = $TargetDir; Type = 'home' }

    # Level 1 — Workspaces
    $workspaces = Get-ChildItem -Path $TargetDir -Directory -ErrorAction SilentlyContinue | Sort-Object Name
    foreach ($ws in $workspaces) {
        if (-not (Test-Path (Join-Path $ws.FullName '.git'))) { continue }
        [PSCustomObject]@{ Level = 1; Path = $ws.FullName; Type = 'workspace' }

        # Level 2 — Projects
        $projects = Get-ChildItem -Path $ws.FullName -Directory -ErrorAction SilentlyContinue | Sort-Object Name
        foreach ($proj in $projects) {
            if (-not (Test-Path (Join-Path $proj.FullName '.git'))) { continue }
            [PSCustomObject]@{ Level = 2; Path = $proj.FullName; Type = 'project' }
        }
    }
}
