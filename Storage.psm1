<# 
.SYNOPSIS
    Storage health module for ASU
#>

function Show-StorageMenu {
    Clear-Host
    Write-Host "=== Storage Health ===" -ForegroundColor Cyan
    
    Get-PhysicalDisk | Format-Table FriendlyName, MediaType, Size, BusType, HealthStatus -AutoSize
    
    $Drives = Get-PSDrive -PSProvider FileSystem
    foreach ($Drive in $Drives) {
        $FreePercent = [math]::Round(($Drive.Free / $Drive.Used) * 100, 1)  # Note: simplistic
        Write-Host "$($Drive.Name): $($Drive.Used/1GB) GB used, $($Drive.Free/1GB) GB free ($FreePercent% free)" -ForegroundColor $(if ($Drive.Free/1GB -lt 10) {"Red"} else {"Green"})
    }
    
    Write-ASULog "Storage diagnostics viewed" -Level "Info"
    Pause
    Show-MainMenu
}

Export-ModuleMember -Function Show-StorageMenu