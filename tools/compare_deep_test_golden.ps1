<#
Compare `tools/deep_test_results.json` with `tools/golden/deep_test_expected.json`.
Exits 0 when matching, 1 when different, 2 when actual missing, 3 when golden missing.
#>
$actualPath = Join-Path -Path $PSScriptRoot -ChildPath 'deep_test_results.json'
$goldenPath = Join-Path -Path $PSScriptRoot -ChildPath 'golden\deep_test_expected.json'

if (-not (Test-Path $actualPath)) {
    Write-Error "Actual deep test results not found at $actualPath"
    exit 2
}
if (-not (Test-Path $goldenPath)) {
    Write-Output "Golden file not found at $goldenPath; skipping comparison."
    exit 3
}

$actualRaw = Get-Content -LiteralPath $actualPath -Raw
$goldenRaw = Get-Content -LiteralPath $goldenPath -Raw

# Normalize JSON by parsing and re-serializing with stable formatting
try {
    $actualObj = $actualRaw | ConvertFrom-Json
    $goldenObj = $goldenRaw | ConvertFrom-Json
} catch {
    Write-Error "Failed to parse JSON: $_"
    exit 4
}

$actualJson = $actualObj | ConvertTo-Json -Depth 100
$goldenJson = $goldenObj | ConvertTo-Json -Depth 100

# Compare line-wise for readable diffs
$actualLines = $actualJson -split "`n"
$goldenLines = $goldenJson -split "`n"
$diff = Compare-Object -ReferenceObject $goldenLines -DifferenceObject $actualLines -SyncWindow 0

if ($diff) {
    Write-Output "Deep test results differ from golden. Writing diff to tools/deep_test_golden_diff.txt"
    $diff | Out-File -FilePath (Join-Path -Path $PSScriptRoot -ChildPath '..\tools\deep_test_golden_diff.txt') -Width 160
    $diff | Format-Table | Out-String | Write-Output
    exit 1
}

Write-Output "Deep test results match golden."
exit 0
