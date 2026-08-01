<#
Tolerant comparator for `tools/deep_test_results.json`.
Checks presence of expected headers/markers instead of exact formatting so
environment-specific columns (timings, path lengths) don't cause failures.

Exits 0 when checks pass, 1 when failures detected, 2 when actual missing.
#>

$actualPath = Join-Path -Path $PSScriptRoot -ChildPath 'deep_test_results.json'
if (-not (Test-Path $actualPath)) {
    Write-Error "Actual deep test results not found at $actualPath"
    exit 2
}

$actual = Get-Content -LiteralPath $actualPath -Raw | ConvertFrom-Json

$failures = @()

# Verify modules imported
foreach ($m in $actual | Where-Object { $_.Module }) {
    if (-not $m.Imported) { $failures += "Module $($m.Module) failed to import" }
    if ($m.Error) { $failures += "Module $($m.Module) reported error: $($m.Error)" }
}

# Heuristic checks for function outputs
function Assert-Contains([string]$name, [string[]]$mustContain) {
    $entry = $actual | Where-Object { $_.Function -eq $name }
    if (-not $entry) { $failures += "Missing result for function $name"; return }
    $out = $entry.Output -replace "`r",""
    foreach ($token in $mustContain) {
        if (-not ($out -match [regex]::Escape($token))) { $failures += "$name output missing token: $token" }
    }
}

Assert-Contains -name 'Show-BatteryMenu' -mustContain @('Battery','report')
Assert-Contains -name 'Show-MemoryMenu' -mustContain @('Name','Memory (MB)')
Assert-Contains -name 'Show-NetworkMenu' -mustContain @('Source','Destination')
Assert-Contains -name 'Show-StorageMenu' -mustContain @('FriendlyName','MediaType')
Assert-Contains -name 'Show-StartupMenu' -mustContain @('Name','Command')

if ($failures.Count -gt 0) {
    Write-Output "Deep test checks failed; writing details to tools/deep_test_golden_diff.txt"
    $failures | Out-File -FilePath (Join-Path -Path $PSScriptRoot -ChildPath '..\\tools\\deep_test_golden_diff.txt') -Width 160
    $failures | ForEach-Object { Write-Output $_ }
    exit 1
}

Write-Output "Deep test checks passed (tolerant comparison)."
exit 0
