#Requires -Version 7
<#
.SYNOPSIS
    Richtet die Gemini CLI status_line in ~/.gemini/config.toml ein.
    Sets up the Gemini CLI status_line in ~/.gemini/config.toml.
.DESCRIPTION
    Windows-Gegenstueck zu setup-gemini-settings.sh.
    Windows counterpart to setup-gemini-settings.sh.

    Liest die zentrale Vorlage scripts/templates/gemini-statusline.toml
    und setzt daraus [tui].status_line in der Gemini-Konfiguration.

    Reads the central template scripts/templates/gemini-statusline.toml
    and sets [tui].status_line in the Gemini configuration.

    Verwendung / Usage:
        pwsh -NoProfile scripts/setup-gemini-settings.ps1           # einrichten
        pwsh -NoProfile scripts/setup-gemini-settings.ps1 -WhatIf   # Vorschau
        pwsh -NoProfile scripts/setup-gemini-settings.ps1 -Force    # ueberschreiben
#>
[CmdletBinding(SupportsShouldProcess)]
param(
    [switch] $Force
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Get-HomeDir {
    if ($env:HOME) {
        return $env:HOME
    }

    return $env:USERPROFILE
}

function Get-StatusLineFromTemplate {
    param(
        [Parameter(Mandatory)]
        [string] $TemplateText
    )

    $match = [regex]::Match($TemplateText, '(?m)^status_line\s*=\s*\[.*\]\s*$')
    if (-not $match.Success) {
        throw 'Fehler / Error: template contains no status_line entry.'
    }

    return $match.Value
}

function Test-HasGeminiStatusLine {
    param(
        [Parameter(Mandatory)]
        [string] $ConfigText
    )

    $lines = [regex]::Split($ConfigText, "\r?\n")
    $inTui = $false

    foreach ($line in $lines) {
        if ($line -match '^\[[^\]]+\]\s*$') {
            $inTui = $line -match '^\[tui\]\s*$'
            continue
        }

        if ($inTui -and $line -match '^\s*status_line\s*=') {
            return $true
        }
    }

    return $false
}

function Set-GeminiStatusLine {
    param(
        [Parameter(Mandatory)]
        [AllowEmptyString()]
        [string] $ConfigText,

        [Parameter(Mandatory)]
        [string] $StatusLine,

        [Parameter(Mandatory)]
        [string] $TemplateText
    )

    if ([string]::IsNullOrEmpty($ConfigText)) {
        $lines = @()
    } else {
        $lines = @([regex]::Split($ConfigText, "\r?\n"))
    }

    while ($lines.Count -gt 0 -and $lines[-1] -eq '') {
        $lines = $lines[0..($lines.Count - 2)]
    }

    $sectionHeaderPattern = '^\[[^\]]+\]\s*$'
    $out = [System.Collections.Generic.List[string]]::new()
    $foundTui = $false
    $i = 0

    while ($i -lt $lines.Count) {
        $line = $lines[$i]

        if ($line -match '^\[tui\]\s*$') {
            $foundTui = $true
            $out.Add('[tui]')
            $i++

            $section = [System.Collections.Generic.List[string]]::new()
            while ($i -lt $lines.Count -and -not ($lines[$i] -match $sectionHeaderPattern)) {
                if ($lines[$i] -notmatch '^\s*status_line\s*=') {
                    $section.Add($lines[$i])
                }
                $i++
            }

            $insertAt = 0
            while ($insertAt -lt $section.Count) {
                $trimmed = $section[$insertAt].Trim()
                if ($trimmed -eq '' -or $section[$insertAt].TrimStart().StartsWith('#')) {
                    $insertAt++
                    continue
                }
                break
            }

            $section.Insert($insertAt, $StatusLine)
            foreach ($entry in $section) {
                $out.Add($entry)
            }
            continue
        }

        $out.Add($line)
        $i++
    }

    if (-not $foundTui) {
        if ($out.Count -gt 0 -and $out[$out.Count - 1].Trim() -ne '') {
            $out.Add('')
        }

        foreach ($line in ($TemplateText.Trim() -split "\r?\n")) {
            $out.Add($line)
        }
    }

    return (($out -join "`n").TrimEnd() + "`n")
}

$scriptDir = $PSScriptRoot
$templateFile = Join-Path $scriptDir 'templates/gemini-statusline.toml'
$settingsDir = if ($env:GEMINI_HOME) { $env:GEMINI_HOME } else { Join-Path (Get-HomeDir) '.gemini' }
$settingsFile = Join-Path $settingsDir 'config.toml'

if (-not (Test-Path $templateFile)) {
    throw "Fehler / Error: template not found: $templateFile"
}

if ($WhatIfPreference) {
    Write-Host "[WhatIf] Wuerde Gemini status_line setzen in / Would set Gemini status_line in: $settingsFile"
    Write-Host "[WhatIf] Vorlage / Template: $templateFile"
    Write-Host "[WhatIf] Elemente / Items: current-dir | git-branch | sandbox | model | context-used"
    return
}

$templateText = Get-Content $templateFile -Raw
$statusLine = Get-StatusLineFromTemplate -TemplateText $templateText

if ((Test-Path $settingsFile) -and -not $Force) {
    $existing = Get-Content $settingsFile -Raw
    if (Test-HasGeminiStatusLine -ConfigText $existing) {
        Write-Host 'Gemini status_line bereits konfiguriert / already configured. Verwende -Force zum Ueberschreiben / Use -Force to overwrite.'
        return
    }
}

if ($PSCmdlet.ShouldProcess($settingsDir, 'Verzeichnis anlegen / Create directory')) {
    New-Item -ItemType Directory -Path $settingsDir -Force | Out-Null
}

$configText = if (Test-Path $settingsFile) { Get-Content $settingsFile -Raw } else { '' }
$updatedText = Set-GeminiStatusLine -ConfigText $configText -StatusLine $statusLine -TemplateText $templateText

if ($PSCmdlet.ShouldProcess($settingsFile, 'Gemini status_line setzen / Set Gemini status_line')) {
    Set-Content -Path $settingsFile -Value $updatedText -Encoding UTF8
    Write-Host "OK  Gemini status_line gesetzt / set in $settingsFile" -ForegroundColor Green
    Write-Host '    Items: current-dir | git-branch | sandbox | model | context-used'
}
