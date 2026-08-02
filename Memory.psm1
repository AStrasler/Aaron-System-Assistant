<#
.SYNOPSIS
    Memory analysis module for ASU
#>

<#
.SYNOPSIS
    Interactive memory usage and top consumer display.

.DESCRIPTION
    Shows installed and usable RAM, current usage percentage, and lists the top 5 memory-consuming processes.

.EXAMPLE
    Show-MemoryMenu
#>
<#
.SYNOPSIS
    Show-MemoryMenu (auto-added help)
#>
function Show-MemoryMenu {
    Clear-Host
    Write-Host "=== Memory Analysis ===" -ForegroundColor Cyan

    $ComputerSystem = Get-CimInstance Win32_ComputerSystem
    $OS = Get-CimInstance Win32_OperatingSystem

    Write-Host "Installed RAM: $([math]::Round($ComputerSystem.TotalPhysicalMemory / 1GB, 2)) GB" -ForegroundColor White
    Write-Host "Usable RAM: $([math]::Round($OS.TotalVisibleMemorySize / 1MB, 2)) GB" -ForegroundColor White
    Write-Host "Current Usage: $([math]::Round(($OS.TotalVisibleMemorySize - $OS.FreePhysicalMemory) / $OS.TotalVisibleMemorySize * 100))%" -ForegroundColor White

    # Top processes
    Write-Host "`nTop 5 Memory Consumers:" -ForegroundColor Yellow
    Get-Process | Sort-Object WorkingSet -Descending | Select-Object -First 5 |
        Format-Table Name, @{Name='Memory (MB)'; Expression={[math]::Round($_.WorkingSet / 1MB, 2)}} -AutoSize

    Write-ASULog "Memory analysis viewed" -Level "Info"
    Pause
    Show-MainMenu
}

function Get-MemorySummary {
    param()
    $ComputerSystem = Get-CimInstance Win32_ComputerSystem
    $OS = Get-CimInstance Win32_OperatingSystem
    $top = Get-Process | Sort-Object WorkingSet -Descending | Select-Object -First 5 | Select-Object Name,@{Name='MemoryMB';Expression={[math]::Round($_.WorkingSet/1MB,2)}}
    return @{ InstalledGB = [math]::Round($ComputerSystem.TotalPhysicalMemory / 1GB, 2); UsableGB = [math]::Round($OS.TotalVisibleMemorySize / 1MB, 2); TopConsumers = $top }
}

Export-ModuleMember -Function Show-MemoryMenu,Get-MemorySummary



