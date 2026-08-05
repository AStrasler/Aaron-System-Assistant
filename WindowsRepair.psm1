<#
.SYNOPSIS
    Windows Repair module for ASU
#>

function Show-WindowsRepairMenu {
    Clear-Host
    Write-Host '=== Windows Repair Tools ===' -ForegroundColor Cyan
    Write-Host '1. Run SFC /scannow' -ForegroundColor White
    Write-Host '2. Run DISM RestoreHealth' -ForegroundColor White
    Write-Host '3. Schedule CHKDSK /f on C: (next reboot)' -ForegroundColor White
    Write-Host '0. Back' -ForegroundColor Yellow
    Write-Host ''

    if (-not (Test-AdminRights)) {
        $continue = Request-Elevation
        if (-not $continue) { return }
        if (-not (Test-AdminRights)) {
            Write-Host 'Administrator rights still required. Aborting.' -ForegroundColor Red
            Pause
            return
        }
    }

    $choice = Read-Host 'Enter choice'
    switch ($choice) {
        '1' {
            $confirm = Read-Host 'SFC can take 10-30+ minutes. Continue? (Y/N)'
            if ($confirm -match '^[Yy]') {
                Write-Host 'Running SFC... do not close this window.' -ForegroundColor Yellow
                sfc /scannow
                Write-ASULog 'SFC scan completed' -Level Info
            }
        }
        '2' {
            $confirm = Read-Host 'DISM can take a long time and needs internet. Continue? (Y/N)'
            if ($confirm -match '^[Yy]') {
                Write-Host 'Running DISM... do not close this window.' -ForegroundColor Yellow
                DISM /Online /Cleanup-Image /RestoreHealth
                Write-ASULog 'DISM RestoreHealth completed' -Level Info
            }
        }
        '3' {
            Write-Host 'This schedules CHKDSK /f on C: for the next reboot.' -ForegroundColor Yellow
            $confirm = Read-Host 'Type YES to confirm'
            if ($confirm -eq 'YES') {
                Write-Host 'Run the following from an elevated prompt if needed:' -ForegroundColor Gray
                Write-Host '  chkdsk C: /f' -ForegroundColor Gray
                Write-ASULog 'CHKDSK schedule requested' -Level Info
            }
        }
        '0' { return }
        default { Write-Host 'Invalid choice' -ForegroundColor Red }
    }
    Pause
}

Export-ModuleMember -Function Show-WindowsRepairMenu