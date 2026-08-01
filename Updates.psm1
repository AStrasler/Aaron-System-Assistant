<#
.SYNOPSIS
    Hardware diagnostics module for ASU
#>

<#
.SYNOPSIS
    Show hardware diagnostics and basic system information.

.DESCRIPTION
    Displays manufacturer, model, BIOS version, CPU and GPU information.

.EXAMPLE
    Show-UpdatesMenu
#>
function Show-UpdatesMenu {
    Clear-Host
    Write-Host "=== Hardware Diagnostics ===" -ForegroundColor Cyan

    # Get system info
    $ComputerSystem = Get-CimInstance Win32_ComputerSystem
    $BIOS = Get-CimInstance Win32_BIOS
    $CPU = Get-CimInstance Win32_Processor | Select-Object -First 1
    $GPU = Get-CimInstance Win32_VideoController | Where-Object { $_.Name -notlike "*Microsoft*" } | Select-Object -First 1

    Write-Host "Manufacturer: $($ComputerSystem.Manufacturer)" -ForegroundColor White
    Write-Host "Model: $($ComputerSystem.Model)" -ForegroundColor White
    Write-Host "Motherboard: $( (Get-CimInstance Win32_BaseBoard).Product )" -ForegroundColor White
    Write-Host "BIOS Version: $($BIOS.Version)" -ForegroundColor White
    Write-Host "CPU: $($CPU.Name) ($($CPU.NumberOfCores) cores)" -ForegroundColor White
    if ($GPU) {
        Write-Host "GPU: $($GPU.Name)" -ForegroundColor White
    }

    Write-ASULog "Hardware diagnostics viewed" -Level "Info"
    Pause
    Show-MainMenu
}

Export-ModuleMember -Function Show-UpdatesMenu

