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

    $computerInfo = Get-ComputerInfo | Out-String

    @"
<html>
<head><title>ASU System Report</title></head>
<body>
<h1>Aaron System Utility Report</h1>
<p>Generated: $(Get-Date)</p>
<h2>System Info</h2>
<pre>$computerInfo</pre>
</body>
</html>
"@ | Out-File -FilePath $ReportFile -Encoding UTF8

    Write-Host "HTML Report generated: $ReportFile" -ForegroundColor Green
    Write-ASULog "Report generated: $ReportFile" -Level 'Info'
    Pause
    Show-MainMenu
}

Export-ModuleMember -Function Show-ReportsMenu