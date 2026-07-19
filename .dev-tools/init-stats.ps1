#Requires -Version 7
# Compatibility entry point; implementation lives in scripts/.
$target = Join-Path $PSScriptRoot '../scripts/init-stats.ps1'
& $target @args
exit $LASTEXITCODE
