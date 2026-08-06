<#
.SYNOPSIS
    Storage health module for ASA
#>

function Show-StorageMenu {
    Clear-Host
    Write-Host "`n  💾 Storage Health" -ForegroundColor Cyan
    Write-Host "  ────────────────" -ForegroundColor Gray

    # ---[ Physical Disks ]---
    Write-Host "`n  📊 Physical Disks:" -ForegroundColor Yellow

    $disks = Get-PhysicalDisk -ErrorAction SilentlyContinue
    if ($disks) {
        foreach ($disk in $disks) {
            $sizeGB = [math]::Round($disk.Size / 1GB, 2)
            $healthColor = if ($disk.HealthStatus -eq 'Healthy') { "Green" } else { "Red" }
            Write-Host ("    {0} ({1})" -f $disk.FriendlyName, $disk.BusType) -ForegroundColor White
            Write-Host ("      Size: {0} GB" -f $sizeGB) -ForegroundColor Gray
            Write-Host ("      Health: {0}" -f $disk.HealthStatus) -ForegroundColor $healthColor
            if ($disk.MediaType) {
                Write-Host ("      Media: {0}" -f $disk.MediaType) -ForegroundColor Gray
            }
            Write-Host ""
        }
    } else {
        Write-Host "    No physical disk information available." -ForegroundColor Gray
    }

    # ---[ Drive Partitions ]---
    Write-Host "  📁 Partitions:" -ForegroundColor Yellow

    $Drives = Get-PSDrive -PSProvider FileSystem -ErrorAction SilentlyContinue |
        Where-Object { $_.Used -and $_.Free }

    if ($Drives) {
        foreach ($Drive in $Drives) {
            $total = $Drive.Used + $Drive.Free
            $FreePercent = if ($total -gt 0) {
                [math]::Round(($Drive.Free / $total) * 100, 1)
            } else { 0 }

            $usedGB = [math]::Round($Drive.Used / 1GB, 2)
            $freeGB = [math]::Round($Drive.Free / 1GB, 2)

            # Color code based on free space
            if ($FreePercent -lt 10) {
                $color = "Red"
                $emoji = "🔴"
            } elseif ($FreePercent -lt 20) {
                $color = "Yellow"
                $emoji = "🟡"
            } else {
                $color = "Green"
                $emoji = "🟢"
            }

            Write-Host ("    {0} {1}:" -f $emoji, $Drive.Name) -ForegroundColor $color
            Write-Host ("      Used: {0} GB" -f $usedGB) -ForegroundColor Gray
            Write-Host ("      Free: {0} GB ({1}%)" -f $freeGB, $FreePercent) -ForegroundColor Gray
        }
    } else {
        Write-Host "    No drive partition information available." -ForegroundColor Gray
    }

    # ---[ Smart Warning ]---
    Write-Host "`n  💡 Tip: For detailed drive health, use CrystalDiskInfo or similar." -ForegroundColor DarkGray

    Write-ASALog "Storage diagnostics viewed" -Level Info
    Pause
}

Export-ModuleMember -Function Show-StorageMenu