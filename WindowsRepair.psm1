<#
.SYNOPSIS
    Windows Repair module for ASU
#>

function Show-WindowsRepairMenu {
    Clear-Host
    Write-Host '=== Windows Repair Tools ===' -ForegroundColor Cyan
    Write-Host '1. Run SFC /scannow (System File Checker)' -ForegroundColor White
    Write-Host '2. Run DISM /Online /Cleanup-Image /RestoreHealth' -ForegroundColor White
    Write-Host '3. Schedule CHKDSK /f on C: for next reboot' -ForegroundColor White
    Write-Host '0. Back to Main Menu' -ForegroundColor Yellow
    Write-Host ''

    $choice = Read-Host 'Enter choice'

    switch ($choice) {
        '1' {
            Write-Host 'Running SFC... this may take several minutes.' -ForegroundColor Yellow
            sfc /scannow
            Write-ASULog 'SFC scan completed' -Level 'Info'
        }
        '2' {
            Write-Host 'Running DISM RestoreHealth... this may take several minutes.' -ForegroundColor Yellow
            DISM /Online /Cleanup-Image /RestoreHealth
            Write-ASULog 'DISM RestoreHealth completed' -Level 'Info'
        }
        '3' {
            Write-Host 'Scheduling CHKDSK /f on C: for next reboot.' -ForegroundColor Yellow
            Write-Output 'Y' | chkdsk C: /f
            Write-ASULog 'CHKDSK scheduled for next reboot' -Level 'Info'
        }
        '0' {
            Show-MainMenu
            return
        }
        default {
            Write-Host 'Invalid choice' -ForegroundColor Red
        }
    }

    Pause
    Show-MainMenu
}

Export-ModuleMember -Function Show-WindowsRepairMenu