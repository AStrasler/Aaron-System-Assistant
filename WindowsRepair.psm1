<#
.SYNOPSIS
    Basic non-destructive Windows diagnostics for troubleshooting.

.DESCRIPTION
    This module provides lightweight, non-invasive diagnostics that
    collect system and service health indicators. It purposefully does
    not perform repairs automatically; it gathers information an admin
    can use to decide on next steps.

.EXAMPLE
    Show-WindowsRepairMenu
#>
function Show-WindowsRepairMenu {
    Clear-Host
    Write-Host "=== Windows Repair: Diagnostics ===" -ForegroundColor Cyan
    Write-Host "Collecting non-destructive diagnostics..." -ForegroundColor Yellow

    try {
        $os = Get-CimInstance Win32_OperatingSystem -ErrorAction Stop | Select-Object Caption, Version, BuildNumber, LastBootUpTime
    } catch {
        $os = $null
    }

    try {
        $volumes = Get-Volume -ErrorAction Stop | Select-Object DriveLetter, FriendlyName, @{Name='FreeGB';Expression={[math]::Round($_.SizeRemaining/1GB,2)}}, @{Name='SizeGB';Expression={[math]::Round($_.Size/1GB,2)}}
    } catch {
        $volumes = $null
    }

    try {
        $services = Get-Service -Name wuauserv,Bits -ErrorAction Stop | Select-Object Name, Status
    } catch {
        $services = $null
    }

    try {
        $disks = Get-PhysicalDisk -ErrorAction SilentlyContinue | Select-Object FriendlyName, MediaType, Size, HealthStatus
    } catch {
        $disks = $null
    }

    if ($os) {
        Write-Host "OS: $($os.Caption)  Version: $($os.Version)  Build: $($os.BuildNumber)"
        Write-Host "Last boot: $($os.LastBootUpTime)"
    } else {
        Write-Host "OS information unavailable." -ForegroundColor Yellow
    }

    if ($volumes) {
        Write-Host "`nVolumes:`n" -NoNewline
        $volumes | Format-Table -AutoSize
    }

    if ($disks) {
        Write-Host "`nPhysical disks:`n" -NoNewline
        $disks | Format-Table -AutoSize
    }

    if ($services) {
        Write-Host "`nKey services status:`n" -NoNewline
        $services | Format-Table -AutoSize
    }

    Write-ASULog "WindowsRepair diagnostics collected" -Level "Info"
    Pause
    Show-MainMenu
}

Export-ModuleMember -Function Show-WindowsRepairMenu

