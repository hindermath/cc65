#Requires -Version 7
# Compatibility entry point; implementation lives in scripts/.
$target = Join-Path $PSScriptRoot '../scripts/check-homogeneity.ps1'
& $target @args
exit $LASTEXITCODE
