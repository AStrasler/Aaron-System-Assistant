<#
.SYNOPSIS
    Storage health module for ASU
#>

function Show-StorageMenu {
    Clear-Host
    Write-Host '=== Storage Health ===' -ForegroundColor Cyan

    Get-PhysicalDisk -ErrorAction SilentlyContinue |
        Format-Table FriendlyName, MediaType, Size, BusType, HealthStatus -AutoSize

    $Drives = Get-PSDrive -PSProvider FileSystem -ErrorAction SilentlyContinue
    foreach ($Drive in $Drives) {
        $total = $Drive.Used + $Drive.Free
        $FreePercent = if ($total -gt 0) {
            [math]::Round(($Drive.Free / $total) * 100, 1)
        }
        else {
            0
        }
        $usedGB = [math]::Round($Drive.Used / 1GB, 2)
        $freeGB = [math]::Round($Drive.Free / 1GB, 2)
        $color = if ($freeGB -lt 10) { 'Red' } else { 'Green' }
        Write-Host "$($Drive.Name): $usedGB GB used, $freeGB GB free ($FreePercent% free)" -ForegroundColor $color
    }

    Write-ASULog 'Storage diagnostics viewed' -Level Info
    Pause
}

Export-ModuleMember -Function Show-StorageMenu