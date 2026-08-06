<#
.SYNOPSIS
    Updates module for ASA
    - Show-UpdatesMenu: list pending updates
    - Show-InstallRestartMenu: download/install updates and restart
#>

function Show-UpdatesMenu {
    Clear-Host
    Write-Host "`n  🔄 Windows Updates" -ForegroundColor Cyan
    Write-Host "  ──────────────────" -ForegroundColor Gray

    Write-Host "`n  🔍 Checking for Windows Update status..." -ForegroundColor Yellow

    try {
        $UpdateSession = New-Object -ComObject Microsoft.Update.Session
        $UpdateSearcher = $UpdateSession.CreateUpdateSearcher()
        $SearchResult = $UpdateSearcher.Search('IsInstalled=0')
        $count = $SearchResult.Updates.Count

        if ($count -gt 0) {
            Write-Host "`n  📋 Pending updates: $count" -ForegroundColor Yellow
            Write-Host "`n  Top pending updates:" -ForegroundColor White

            $i = 0
            $SearchResult.Updates | ForEach-Object {
                $i++
                if ($i -le 10) {
                    $title = if ($_.Title.Length -gt 70) { "$($_.Title.Substring(0, 70))..." } else { $_.Title }
                    Write-Host ("    - {0}" -f $title) -ForegroundColor Gray
                }
            }
            if ($count -gt 10) {
                Write-Host ("    ... and {0} more" -f ($count - 10)) -ForegroundColor Gray
            }
        } else {
            Write-Host "`n  ✅ No pending updates found." -ForegroundColor Green
        }
    }
    catch {
        Write-Host "`n  ⚠️ Unable to query Windows Update." -ForegroundColor Yellow
        Write-Host "     Use Settings > Windows Update instead." -ForegroundColor Gray
        Write-ASALog "Windows Update check failed: $_" -Level Warning
    }

    Write-ASALog "Updates check performed" -Level Info
    Pause
}

function Show-InstallRestartMenu {
    Clear-Host
    Write-Host "`n  🔄 Install Updates & Restart" -ForegroundColor Cyan
    Write-Host "  ────────────────────────────" -ForegroundColor Gray
    Write-Host ""
    Write-Host "  This will:" -ForegroundColor Yellow
    Write-Host "    1. Search for pending Windows updates" -ForegroundColor Gray
    Write-Host "    2. Download and install them" -ForegroundColor Gray
    Write-Host "    3. Restart this PC so changes can apply" -ForegroundColor Gray
    Write-Host ""
    Write-Host "  ⚠️ Save your work before continuing." -ForegroundColor Yellow
    Write-Host ""

    # Check admin rights
    if (-not (Test-AdminRights)) {
        Write-Host "  ❌ Administrator rights required for this operation." -ForegroundColor Red
        Write-Host "  💡 Run ASA as Administrator and try again." -ForegroundColor Gray
        Pause
        return
    }

    $confirm = Read-Host '  Type YES to install updates and restart'
    if ($confirm -ne 'YES') {
        Write-Host "  Cancelled." -ForegroundColor Yellow
        Pause
        return
    }

    try {
        Write-Host "`n  🔍 Searching for updates..." -ForegroundColor Yellow

        $session  = New-Object -ComObject Microsoft.Update.Session
        $searcher = $session.CreateUpdateSearcher()
        $result   = $searcher.Search('IsInstalled=0 and Type=''Software''')

        $count = $result.Updates.Count
        if ($count -eq 0) {
            Write-Host "  ✅ No pending software updates found." -ForegroundColor Green
            Write-ASALog "Install/restart: no updates pending" -Level Info

            $rebootOnly = Read-Host "`n  Restart anyway? (Y/N)"
            if ($rebootOnly -match '^[Yy]') {
                Write-Host "`n  🔄 Restarting in 60 seconds. Close other apps now." -ForegroundColor Yellow
                Write-ASALog "User requested restart with no updates" -Level Info
                shutdown.exe /r /t 60 /c "ASA: Restart requested"
            }
            Pause
            return
        }

        Write-Host "  📋 Found $count update(s). Downloading..." -ForegroundColor Yellow

        $downloader = $session.CreateUpdateDownloader()
        $downloader.Updates = $result.Updates
        $downloadResult = $downloader.Download()

        if ($downloadResult.ResultCode -ne 2) {
            Write-Host "  ⚠️ Download finished with result code $($downloadResult.ResultCode)." -ForegroundColor Yellow
            Write-Host "     Continuing to install if possible..." -ForegroundColor Gray
        } else {
            Write-Host "  ✅ Download complete." -ForegroundColor Green
        }

        Write-Host "`n  📦 Installing updates (this can take a long time)..." -ForegroundColor Yellow
        Write-Host "  ⚠️ Do not close this window." -ForegroundColor Yellow

        $installer = $session.CreateUpdateInstaller()
        $installer.Updates = $result.Updates
        $installResult = $installer.Install()

        Write-Host "`n  ✅ Install result code: $($installResult.ResultCode)" -ForegroundColor White
        Write-ASALog "Updates install result code: $($installResult.ResultCode)" -Level Info

        Write-Host "`n  🔄 Restarting in 90 seconds so updates can finish applying." -ForegroundColor Yellow
        Write-Host "  💡 Save work now. To cancel restart, run: shutdown /a" -ForegroundColor Gray
        shutdown.exe /r /t 90 /c "ASA: Restarting to apply Windows updates"
        Write-ASALog "Restart scheduled after update install" -Level Info
    }
    catch {
        Write-Host "`n  ❌ Update install failed: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "  💡 You can still use Settings > Windows Update, or restart manually later." -ForegroundColor Yellow
        Write-ASALog "Install/restart failed: $_" -Level Error
    }

    Pause
}

Export-ModuleMember -Function Show-UpdatesMenu, Show-InstallRestartMenu