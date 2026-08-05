<#
.SYNOPSIS
    Battery analysis module for ASU
#>

function Show-BatteryMenu {
    Clear-Host
    Write-Host '=== Battery Analysis ===' -ForegroundColor Cyan

    $reportPath = Join-Path $env:TEMP 'battery-report.html'
    try {
        powercfg /batteryreport /output $reportPath | Out-Null
        Write-Host "Battery report generated at $reportPath" -ForegroundColor Green
    }
    catch {
        Write-Host "Failed to generate battery report: $_" -ForegroundColor Red
    }

    $Battery = Get-CimInstance -ClassName Win32_Battery -ErrorAction SilentlyContinue
    if ($Battery) {
        Write-Host "Battery Status: $($Battery.Status)" -ForegroundColor White
        if ($null -ne $Battery.EstimatedChargeRemaining) {
            Write-Host "Estimated Charge Remaining: $($Battery.EstimatedChargeRemaining)%" -ForegroundColor White
        }
    }
    else {
        Write-Host 'No battery detected (Desktop system)' -ForegroundColor Yellow
    }

    Write-ASULog 'Battery report generated' -Level Info
    Pause
}

Export-ModuleMember -Function Show-BatteryMenu