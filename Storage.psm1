<#
.SYNOPSIS
    Storage health module for ASU
#>

<#
.SYNOPSIS
    Display storage health and drive usage summaries.

.DESCRIPTION
    Shows physical disk health and a simple per-drive usage summary.

.EXAMPLE
    Show-StorageMenu
#>
function Show-StorageMenu {
    Clear-Host
    Write-Host "=== Storage Health ===" -ForegroundColor Cyan

    Get-PhysicalDisk | Format-Table FriendlyName, MediaType, Size, BusType, HealthStatus -AutoSize

    $Drives = Get-PSDrive -PSProvider FileSystem
    foreach ($Drive in $Drives) {
        $TotalBytes = [double]$Drive.Used + [double]$Drive.Free
        $FreePercent = if ($TotalBytes -gt 0) { [math]::Round(([double]$Drive.Free / $TotalBytes) * 100, 1) } else { 0 }
        $FreeGB = [math]::Round([double]$Drive.Free / 1GB, 2)
        $UsedGB = [math]::Round([double]$Drive.Used / 1GB, 2)
        Write-Host "$($Drive.Name): $UsedGB GB used, $FreeGB GB free ($FreePercent% free)" -ForegroundColor $(if ($FreeGB -lt 10) {"Red"} else {"Green"})
    }

    Write-ASULog "Storage diagnostics viewed" -Level "Info"
    Pause
    Show-MainMenu
}

function Get-StorageSummary {
    param()
    $disks = Get-PhysicalDisk -ErrorAction SilentlyContinue | Select-Object FriendlyName, MediaType, Size, BusType, HealthStatus
    $drives = Get-PSDrive -PSProvider FileSystem | ForEach-Object {
        [PSCustomObject]@{ Name = $_.Name; UsedGB = [math]::Round($_.Used/1GB,2); FreeGB = [math]::Round($_.Free/1GB,2) }
    }
    return @{ Disks = $disks; Drives = $drives }
}

Export-ModuleMember -Function Show-StorageMenu,Get-StorageSummary



