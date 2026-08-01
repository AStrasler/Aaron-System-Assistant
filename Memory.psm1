<# 
.SYNOPSIS
    Memory analysis module for ASU
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

Export-ModuleMember -Function Show-MemoryMenu