<#
.SYNOPSIS
    Reports module for ASU
#>

<#
.SYNOPSIS
    Generate an HTML system report and save it to the configured Reports directory.

.DESCRIPTION
    Produces a basic HTML report containing system information and saves it under the ASU reports folder.

.EXAMPLE
    Show-ReportsMenu
#>
function Show-ReportsMenu {
    Clear-Host
    $ReportPath = Get-ASUReportPath
    if (-not (Test-Path $ReportPath)) { New-Item -Path $ReportPath -ItemType Directory -Force | Out-Null }

    $ReportFile = Join-Path $ReportPath "ASU_Report_$(Get-Date -Format 'yyyyMMdd_HHmmss').html"

    # Basic HTML report
    @"
<html><head><title>ASU System Report</title></head><body>
<h1>Aaron System Utility Report</h1>
<p>Generated: $(Get-Date)</p>
<h2>System Info</h2>
<pre>$(Get-ComputerInfo | Out-String)</pre>
</body></html>
"@ | Out-File $ReportFile -Encoding UTF8

    Write-Host "HTML Report generated: $ReportFile" -ForegroundColor Green
    Write-ASULog "Report generated: $ReportFile" -Level "Info"
    Pause
    Show-MainMenu
}

Export-ModuleMember -Function Show-ReportsMenu

