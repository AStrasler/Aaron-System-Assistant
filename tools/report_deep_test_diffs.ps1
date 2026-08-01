$actualPath = Join-Path $PSScriptRoot '..\tools\deep_test_results.json'
$goldenPath = Join-Path $PSScriptRoot '..\tools\golden\deep_test_expected.json'
$a = Get-Content -LiteralPath $actualPath -Raw | ConvertFrom-Json
$g = Get-Content -LiteralPath $goldenPath -Raw | ConvertFrom-Json
$diffs = @()
foreach ($gold in $g) {
    if ($null -ne $gold.Function) {
        $name = $gold.Function
        $act = $a | Where-Object { $_.Function -eq $name }
        if (-not $act) { $diffs += "Missing function result: $name"; continue }
        if ($gold.Output -ne $act.Output) {
            $linesG = ($gold.Output -replace "`r","") -split "`n"
            $linesA = ($act.Output -replace "`r","") -split "`n"
            $snipG = ($linesG | Select-Object -First 3) -join ' | '
            $snipA = ($linesA | Select-Object -First 3) -join ' | '
            $diffs += "Function $name output differs`n  golden: $snipG`n  actual: $snipA"
        }
    } elseif ($null -ne $gold.Module) {
        $m = $gold.Module
        $actm = $a | Where-Object { $_.Module -eq $m }
        if (-not $actm) { $diffs += "Missing module entry: $m"; continue }
        if ($gold.Imported -ne $actm.Imported -or $gold.Error -ne $actm.Error) {
            $diffs += "Module $m import/error differs (golden: Imported=$($gold.Imported) Error=$($gold.Error); actual: Imported=$($actm.Imported) Error=$($actm.Error))"
        }
    }
}
if (-not $diffs) { Write-Output 'No diffs'; exit 0 } else { $diffs | ForEach-Object { Write-Output $_; Write-Output '' }; exit 1 }