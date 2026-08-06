<#
.SYNOPSIS
    Memory analysis module for ASA
#>

function Show-MemoryMenu {
    Clear-Host
    Write-Host "`n  🧠 Memory Analysis" -ForegroundColor Cyan
    Write-Host "  ──────────────────" -ForegroundColor Gray

    $ComputerSystem = Get-CimInstance -ClassName Win32_ComputerSystem -ErrorAction SilentlyContinue
    $OS = Get-CimInstance -ClassName Win32_OperatingSystem -ErrorAction SilentlyContinue

    if (-not $ComputerSystem -or -not $OS) {
        Write-Host "  ❌ Failed to retrieve system memory information." -ForegroundColor Red
        Pause
        return
    }

    $installedGB = [math]::Round($ComputerSystem.TotalPhysicalMemory / 1GB, 2)
    $usableGB = [math]::Round($OS.TotalVisibleMemorySize / 1MB, 2)
    $freeGB = [math]::Round($OS.FreePhysicalMemory / 1MB, 2)
    $usedGB = $usableGB - $freeGB
    $usagePercent = [math]::Round(($usedGB / $usableGB) * 100)

    # Color-code the usage percentage
    $usageColor = if ($usagePercent -gt 80) { "Red" } elseif ($usagePercent -gt 60) { "Yellow" } else { "Green" }

    Write-Host ""
    Write-Host "  📊 Memory Summary:" -ForegroundColor Yellow
    Write-Host "    Installed RAM  : $installedGB GB" -ForegroundColor White
    Write-Host "    Usable RAM     : $usableGB GB" -ForegroundColor White
    Write-Host "    Used RAM       : $usedGB GB" -ForegroundColor White
    Write-Host "    Free RAM       : $freeGB GB" -ForegroundColor White
    Write-Host "    Usage          : $usagePercent%" -ForegroundColor $usageColor

    Write-Host "`n  📋 Top 5 Memory Consumers:" -ForegroundColor Yellow
    $topProcesses = Get-Process | Sort-Object WorkingSet -Descending | Select-Object -First 5

    if ($topProcesses) {
        foreach ($proc in $topProcesses) {
            $memMB = [math]::Round($proc.WorkingSet / 1MB, 2)
            $color = if ($memMB -gt 500) { "Red" } elseif ($memMB -gt 100) { "Yellow" } else { "White" }
            Write-Host "    $($proc.Name) : $memMB MB" -ForegroundColor $color
        }
    } else {
        Write-Host "    No process data available." -ForegroundColor Gray
    }

    Write-ASALog "Memory analysis viewed (Usage: $usagePercent%)" -Level Info
    Pause
}

Export-ModuleMember -Function Show-MemoryMenu