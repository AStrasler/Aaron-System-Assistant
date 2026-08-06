<#
.SYNOPSIS
    Battery analysis module for ASA
#>

function Show-BatteryMenu {
    Clear-Host
    Write-Host "`n  🔋 Battery Management" -ForegroundColor Cyan
    Write-Host "  ─────────────────────" -ForegroundColor Gray

    $reportPath = Join-Path $env:TEMP "battery-report.html"
    try {
        powercfg /batteryreport /output $reportPath 2>$null
        if (Test-Path $reportPath) {
            Write-Host "  ✅ Battery report generated:" -ForegroundColor Green
            Write-Host "     $reportPath" -ForegroundColor Gray
        } else {
            Write-Host "  ⚠️ Battery report could not be generated." -ForegroundColor Yellow
        }
    }
    catch {
        Write-Host "  ❌ Failed to generate battery report: $_" -ForegroundColor Red
    }

    $Battery = Get-CimInstance -ClassName Win32_Battery -ErrorAction SilentlyContinue
    if ($Battery) {
        Write-Host "`n  📊 Battery Status: $($Battery.Status)" -ForegroundColor White
        if ($null -ne $Battery.EstimatedChargeRemaining) {
            Write-Host "  🔋 Estimated Charge: $($Battery.EstimatedChargeRemaining)%" -ForegroundColor White
        }
        if ($null -ne $Battery.EstimatedRunTime) {
            $mins = [math]::Round($Battery.EstimatedRunTime / 60)
            Write-Host "  ⏱️ Estimated Run Time: $mins minutes" -ForegroundColor White
        }
    }
    else {
        Write-Host "`n  💻 No battery detected (Desktop system)" -ForegroundColor Yellow
    }

    Write-ASALog "Battery report generated" -Level Info
    Pause
}

Export-ModuleMember -Function Show-BatteryMenu