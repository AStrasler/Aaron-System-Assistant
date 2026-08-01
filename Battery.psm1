<# 
.SYNOPSIS
    Battery analysis module for ASU
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

Export-ModuleMember -Function Show-BatteryMenu