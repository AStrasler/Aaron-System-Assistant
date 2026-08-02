<#
.SYNOPSIS
    Battery analysis module for ASU
#>

<#
.SYNOPSIS
    Interactive battery analysis and report generation.

.DESCRIPTION
    Generates a Windows battery report, displays battery status if present, and logs the action.

.EXAMPLE
    Show-BatteryMenu
#>
<#
.SYNOPSIS
    Show-BatteryMenu (auto-added help)
#>
function Show-BatteryMenu {
    Clear-Host
    Write-Host "=== Battery Analysis ===" -ForegroundColor Cyan

    # Power report
    powercfg /batteryreport /output "$env:TEMP\battery-report.html"
    Write-Host "Battery report generated at $env:TEMP\battery-report.html" -ForegroundColor Green

    $Battery = Get-CimInstance Win32_Battery
    if ($Battery) {
        Write-Host "Battery Status: $($Battery.Status)" -ForegroundColor White
    } else {
        Write-Host "No battery detected (Desktop system)" -ForegroundColor Yellow
    }

    Write-ASULog "Battery report generated" -Level "Info"
    Pause
    Show-MainMenu
}

function Invoke-BatteryReport {
    param(
        [string]$OutputPath
    )
    $out = if ($OutputPath) { $OutputPath } else { Join-Path $env:TEMP 'battery-report.html' }
    powercfg /batteryreport /output "$out"
    $battery = Get-CimInstance -ClassName Win32_Battery -ErrorAction SilentlyContinue
    return @{ Report = $out; Battery = $battery }
}

Export-ModuleMember -Function Show-BatteryMenu,Invoke-BatteryReport



