<#
.SYNOPSIS
    Memory analysis module for ASU
#>

function Show-MemoryMenu {
    Clear-Host
    Write-Host '=== Memory Analysis ===' -ForegroundColor Cyan

    $ComputerSystem = Get-CimInstance -ClassName Win32_ComputerSystem
    $OS = Get-CimInstance -ClassName Win32_OperatingSystem

    $installedGB = [math]::Round($ComputerSystem.TotalPhysicalMemory / 1GB, 2)
    $usableGB = [math]::Round($OS.TotalVisibleMemorySize / 1MB, 2)
    $usagePercent = [math]::Round((($OS.TotalVisibleMemorySize - $OS.FreePhysicalMemory) / $OS.TotalVisibleMemorySize) * 100)

    Write-Host "Installed RAM: $installedGB GB" -ForegroundColor White
    Write-Host "Usable RAM: $usableGB GB" -ForegroundColor White
    Write-Host "Current Usage: $usagePercent%" -ForegroundColor White

    Write-Host "`nTop 5 Memory Consumers:" -ForegroundColor Yellow
    Get-Process |
        Sort-Object WorkingSet -Descending |
        Select-Object -First 5 |
        Format-Table Name, @{Name = 'Memory (MB)'; Expression = { [math]::Round($_.WorkingSet / 1MB, 2) }} -AutoSize

    Write-ASULog 'Memory analysis viewed' -Level Info
    Pause
}

Export-ModuleMember -Function Show-MemoryMenu