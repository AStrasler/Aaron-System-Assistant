<#
Normalize `tools/deep_test_results.json` into structured JSON suitable for strict comparison.
Produces `tools/deep_test_results_normalized.json`.
#>
$inPath = Join-Path $PSScriptRoot 'deep_test_results.json'
$outPath = Join-Path $PSScriptRoot 'deep_test_results_normalized.json'
if (-not (Test-Path $inPath)) { Write-Error "Missing $inPath"; exit 2 }
$raw = Get-Content -LiteralPath $inPath -Raw | ConvertFrom-Json

$norm = @()
foreach ($item in $raw) {
    if ($null -ne $item.Module) {
        $norm += @{ Type='Module'; Module=$item.Module; Imported=[bool]$item.Imported; Error=$item.Error }
    } elseif ($null -ne $item.Function) {
        $f = $item.Function
        $o = $item.Output -replace "`r",""
        switch ($f) {
            'Show-MemoryMenu' {
                $lines = $o -split "`n" | Where-Object { $_ -match '\S' }
                # skip header lines
                $data = @()
                if ($lines.Count -gt 2) {
                    $rows = $lines[2..($lines.Count-1)]
                    foreach ($r in $rows) {
                        $cols = ($r -replace '\s{2,}','|') -split '\|' | ForEach-Object { $_.Trim() }
                        if ($cols.Count -ge 2) { $data += @{ Name=$cols[0]; MemoryMB = [double]($cols[1] -replace ',','') } }
                    }
                }
                $norm += @{ Type='Function'; Function=$f; Data=$data }
            }
            'Show-NetworkMenu' {
                $lines = $o -split "`n" | Where-Object { $_ -match '\S' }
                $data = @()
                if ($lines.Count -gt 2) {
                    $rows = $lines[2..($lines.Count-1)]
                    foreach ($r in $rows) {
                        $cols = ($r -replace '\s{2,}','|') -split '\|' | ForEach-Object { $_.Trim() }
                        if ($cols.Count -ge 4) { $data += @{ Source=$cols[0]; Destination=$cols[1]; IPV4=$cols[2]; Bytes=$cols[3]; TimeMs = if ($cols.Count -gt 4) { [int]($cols[4]) } else { $null } } }
                    }
                }
                $norm += @{ Type='Function'; Function=$f; Data=$data }
            }
            'Show-StorageMenu' {
                $lines = $o -split "`n" | Where-Object { $_ -match '\S' }
                $data = @()
                if ($lines.Count -gt 2) {
                    $rows = $lines[2..($lines.Count-1)]
                    foreach ($r in $rows) {
                        $cols = ($r -replace '\s{2,}','|') -split '\|' | ForEach-Object { $_.Trim() }
                        if ($cols.Count -ge 4) { $data += @{ FriendlyName=$cols[0]; MediaType=$cols[1]; Size=$cols[2]; Health=$cols[3] } }
                    }
                }
                $norm += @{ Type='Function'; Function=$f; Data=$data }
            }
            'Show-StartupMenu' {
                $lines = $o -split "`n" | Where-Object { $_ -match '\S' }
                $data = @()
                if ($lines.Count -gt 2) {
                    $rows = $lines[2..($lines.Count-1)]
                    foreach ($r in $rows) {
                        $cols = ($r -replace '\s{2,}','|') -split '\|' | ForEach-Object { $_.Trim() }
                        if ($cols.Count -ge 2) { $data += @{ Name=$cols[0]; Command=$cols[1] } }
                    }
                }
                $norm += @{ Type='Function'; Function=$f; Data=$data }
            }
            'Show-BatteryMenu' {
                # extract path
                $m = [regex]::Match($o,'file path (.+)\.')
                $path = if ($m.Success) { $m.Groups[1].Value.Trim() } else { $null }
                $norm += @{ Type='Function'; Function=$f; Data=@{ ReportPath=$path } }
            }
            default {
                $norm += @{ Type='Function'; Function=$f; Data=@{ Raw = $o } }
            }
        }
    }
}

$norm | ConvertTo-Json -Depth 10 | Out-File -FilePath $outPath -Encoding UTF8
Write-Output "Wrote normalized output to $outPath"
exit 0
