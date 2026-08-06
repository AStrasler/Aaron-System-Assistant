<#
.SYNOPSIS
    Windows Repair module for ASA
#>

function Show-WindowsRepairMenu {
    Clear-Host
    Write-Host "`n  🔧 Windows Repair Tools" -ForegroundColor Cyan
    Write-Host "  ──────────────────────" -ForegroundColor Gray
    Write-Host ""
    Write-Host "  1. Run SFC /scannow" -ForegroundColor White
    Write-Host "  2. Run DISM RestoreHealth" -ForegroundColor White
    Write-Host "  3. Schedule CHKDSK /f on C: (next reboot)" -ForegroundColor White
    Write-Host "  0. Back" -ForegroundColor Yellow
    Write-Host ""

    # Check admin rights
    if (-not (Test-AdminRights)) {
        Write-Host "  ⚠️ Administrator rights required for repairs." -ForegroundColor Yellow
        Write-Host "  💡 Run ASA as Administrator and try again." -ForegroundColor Gray
        Pause
        return
    }

    $choice = Read-Host "  Enter choice"
    switch ($choice) {
        '1' {
            Write-Host ""
            $confirm = Read-Host '  SFC can take 10-30+ minutes. Continue? (Y/N)'
            if ($confirm -match '^[Yy]') {
                Write-Host ""
                Write-Host "  🔍 Running SFC /scannow..." -ForegroundColor Yellow
                Write-Host "  ⚠️ Do not close this window." -ForegroundColor Yellow
                Write-Host ""
                sfc /scannow
                Write-Host ""
                Write-Host "  ✅ SFC scan completed." -ForegroundColor Green
                Write-ASALog "SFC scan completed" -Level Info
            } else {
                Write-Host "  Cancelled." -ForegroundColor Yellow
            }
        }
        '2' {
            Write-Host ""
            $confirm = Read-Host '  DISM can take a long time and needs internet. Continue? (Y/N)'
            if ($confirm -match '^[Yy]') {
                Write-Host ""
                Write-Host "  🔍 Running DISM /Online /Cleanup-Image /RestoreHealth..." -ForegroundColor Yellow
                Write-Host "  ⚠️ Do not close this window." -ForegroundColor Yellow
                Write-Host ""
                DISM /Online /Cleanup-Image /RestoreHealth
                Write-Host ""
                Write-Host "  ✅ DISM RestoreHealth completed." -ForegroundColor Green
                Write-ASALog "DISM RestoreHealth completed" -Level Info
            } else {
                Write-Host "  Cancelled." -ForegroundColor Yellow
            }
        }
        '3' {
            Write-Host ""
            Write-Host "  🔄 This schedules CHKDSK /f on C: for the next reboot." -ForegroundColor Yellow
            Write-Host "  ⚠️ This will check the disk for errors on next restart." -ForegroundColor Gray
            Write-Host ""
            $confirm = Read-Host '  Type YES to schedule CHKDSK'
            if ($confirm -eq 'YES') {
                try {
                    chkdsk C: /f
                    Write-Host ""
                    Write-Host "  ✅ CHKDSK scheduled for next reboot." -ForegroundColor Green
                    Write-ASALog "CHKDSK schedule requested" -Level Info
                } catch {
                    Write-Host "  ❌ Failed to schedule CHKDSK: $_" -ForegroundColor Red
                    Write-ASALog "CHKDSK schedule failed: $_" -Level Error
                }
            } else {
                Write-Host "  Cancelled." -ForegroundColor Yellow
            }
        }
        '0' {
            return
        }
        default {
            Write-Host "  ❌ Invalid choice." -ForegroundColor Red
        }
    }
    Pause
}

Export-ModuleMember -Function Show-WindowsRepairMenu