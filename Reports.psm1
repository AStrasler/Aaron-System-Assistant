<#
.SYNOPSIS
    Reports module for ASU
#>

function Show-ReportsMenu {
    Clear-Host
    Write-Host '=== Generate Reports ===' -ForegroundColor Cyan

    $ReportPath = Join-Path $global:ScriptPath 'Reports'
    if (-not (Test-Path $ReportPath)) {
        New-Item -Path $ReportPath -ItemType Directory -Force | Out-Null
    }

    $ReportFile = Join-Path $ReportPath ("ASU_Report_{0}.html" -f (Get-Date -Format 'yyyyMMdd_HHmmss'))

    $os   = Get-CimInstance Win32_OperatingSystem
    $cs   = Get-CimInstance Win32_ComputerSystem
    $cpu  = Get-CimInstance Win32_Processor | Select-Object -First 1
    $bios = Get-CimInstance Win32_BIOS

    $html = @"
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <title>ASU System Report</title>
  <style>
    body { font-family: Segoe UI, Arial, sans-serif; margin: 2rem; background: #f8f9fa; color: #212529; }
    h1 { color: #0d6efd; }
    h2 { border-bottom: 2px solid #0d6efd; padding-bottom: 0.3rem; margin-top: 2rem; }
    table { border-collapse: collapse; width: 100%; max-width: 800px; }
    th, td { text-align: left; padding: 8px 12px; border-bottom: 1px solid #dee2e6; }
    th { width: 220px; background: #e9ecef; }
  </style>
</head>
<body>
  <h1>Aaron System Utility Report</h1>
  <p>Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')</p>
  <h2>System</h2>
  <table>
    <tr><th>Computer Name</th><td>$($cs.Name)</td></tr>
    <tr><th>Manufacturer</th><td>$($cs.Manufacturer)</td></tr>
    <tr><th>Model</th><td>$($cs.Model)</td></tr>
    <tr><th>OS</th><td>$($os.Caption) (Build $($os.BuildNumber))</td></tr>
    <tr><th>Install Date</th><td>$($os.InstallDate)</td></tr>
  </table>
  <h2>Hardware</h2>
  <table>
    <tr><th>CPU</th><td>$($cpu.Name)</td></tr>
    <tr><th>Cores / Logical</th><td>$($cpu.NumberOfCores) / $($cpu.NumberOfLogicalProcessors)</td></tr>
    <tr><th>Total RAM</th><td>$([math]::Round($cs.TotalPhysicalMemory/1GB,2)) GB</td></tr>
    <tr><th>BIOS</th><td>$($bios.SMBIOSBIOSVersion)</td></tr>
  </table>
  <h2>Memory Snapshot</h2>
  <table>
    <tr><th>Free Physical</th><td>$([math]::Round($os.FreePhysicalMemory/1MB,2)) GB</td></tr>
    <tr><th>Total Visible</th><td>$([math]::Round($os.TotalVisibleMemorySize/1MB,2)) GB</td></tr>
  </table>
</body>
</html>
"@

    $html | Out-File -FilePath $ReportFile -Encoding UTF8
    Write-Host "Report saved: $ReportFile" -ForegroundColor Green
    Write-ASULog "Report generated: $ReportFile" -Level Info

    $open = Read-Host 'Open report now? (Y/N)'
    if ($open -match '^[Yy]') { Start-Process $ReportFile }

    Pause
}

Export-ModuleMember -Function Show-ReportsMenu