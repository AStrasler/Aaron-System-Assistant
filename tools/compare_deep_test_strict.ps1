<#
Strict comparator: compares `tools/deep_test_results_normalized.json` to
`tools/golden/deep_test_expected_normalized.json` exactly (structural equality).
Exits 0 on match, 1 on mismatch.
#>
$actual = Join-Path $PSScriptRoot 'deep_test_results_normalized.json'
$golden = Join-Path $PSScriptRoot 'golden\deep_test_expected_normalized.json'
if (-not (Test-Path $actual)) { Write-Error "Missing $actual"; exit 2 }
if (-not (Test-Path $golden)) { Write-Error "Missing $golden"; exit 3 }

$act = Get-Content -Raw $actual | ConvertFrom-Json
$gol = Get-Content -Raw $golden | ConvertFrom-Json

$actJson = $act | ConvertTo-Json -Depth 10
$golJson = $gol | ConvertTo-Json -Depth 10

if ($actJson -ne $golJson) {
    Write-Output "Normalized deep test output does not match golden. Writing diff to tools/deep_test_normalized_diff.txt"
    $diff = Compare-Object -ReferenceObject ($golJson -split "`n") -DifferenceObject ($actJson -split "`n") -SyncWindow 0
    $diff | Out-File -FilePath (Join-Path $PSScriptRoot '..\tools\deep_test_normalized_diff.txt') -Width 200
    $diff | Format-Table | Out-String | Write-Output
    exit 1
}
Write-Output "Normalized deep test output matches golden."
exit 0
