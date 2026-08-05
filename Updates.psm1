<#
.SYNOPSIS
    Updates module for ASU
    - Show-UpdatesMenu: list pending updates
    - Show-InstallRestartMenu: download/install updates and restart
#>

function Show-UpdatesMenu {
    Clear-Host
    Write-Host '=== Windows Updates ===' -ForegroundColor Cyan
    Write-Host 'Checking for Windows Update status...' -ForegroundColor Yellow

    try {
        $UpdateSession = New-Object -ComObject Microsoft.Update.Session
        $UpdateSearcher = $UpdateSession.CreateUpdateSearcher()
        $SearchResult = $UpdateSearcher.Search('IsInstalled=0')
        $count = $SearchResult.Updates.Count

        Write-Host "Pending updates: $count" -ForegroundColor $(if ($count -gt 0) { 'Yellow' } else { 'Green' })

        if ($count -gt 0) {
            Write-Host "`nTop pending updates:" -ForegroundColor White
            $SearchResult.Updates | Select-Object -First 10 | ForEach-Object {
                Write-Host " - $($_.Title)" -ForegroundColor Gray
            }
        }
    }
    catch {
        Write-Host 'Unable to query Windows Update. Use Settings > Windows Update instead.' -ForegroundColor Yellow
        Write-ASULog "Windows Update check failed: $_" -Level Warning
    }

    Write-ASULog 'Updates check performed' -Level Info
    Pause
}

function Show-InstallRestartMenu {
    Clear-Host
    Write-Host '=== Install Updates & Restart ===' -ForegroundColor Cyan
    Write-Host ''
    Write-Host 'This will:' -ForegroundColor Yellow
    Write-Host '  1. Search for pending Windows updates' -ForegroundColor Gray
    Write-Host '  2. Download and install them' -ForegroundColor Gray
    Write-Host '  3. Restart this PC so changes can apply' -ForegroundColor Gray
    Write-Host ''
    Write-Host 'Save your work before continuing.' -ForegroundColor Yellow
    Write-Host ''

    if (-not (Test-AdminRights)) {
        $continue = Request-Elevation
        if (-not $continue) { return }
        if (-not (Test-AdminRights)) {
            Write-Host 'Administrator rights required. Aborting.' -ForegroundColor Red
            Pause
            return
        }
    }

    $confirm = Read-Host 'Type YES to install updates and restart'
    if ($confirm -ne 'YES') {
        Write-Host 'Cancelled.' -ForegroundColor Yellow
        Pause
        return
    }

    try {
        Write-Host ''
        Write-Host 'Searching for updates...' -ForegroundColor Yellow
        $session  = New-Object -ComObject Microsoft.Update.Session
        $searcher = $session.CreateUpdateSearcher()
        $result   = $searcher.Search('IsInstalled=0 and Type=''Software''')

        $count = $result.Updates.Count
        if ($count -eq 0) {
            Write-Host 'No pending software updates found.' -ForegroundColor Green
            Write-ASULog 'Install/restart: no updates pending' -Level Info

            $rebootOnly = Read-Host 'Restart anyway? (Y/N)'
            if ($rebootOnly -match '^[Yy]') {
                Write-Host 'Restarting in 60 seconds. Close other apps now.' -ForegroundColor Yellow
                Write-ASULog 'User requested restart with no updates' -Level Info
                shutdown.exe /r /t 60 /c "ASU: Restart requested"
            }
            Pause
            return
        }

        Write-Host "Found $count update(s). Downloading..." -ForegroundColor Yellow
        $downloader = $session.CreateUpdateDownloader()
        $downloader.Updates = $result.Updates
        $downloadResult = $downloader.Download()

        if ($downloadResult.ResultCode -ne 2) {
            Write-Host "Download finished with result code $($downloadResult.ResultCode). Continuing to install if possible..." -ForegroundColor Yellow
        } else {
            Write-Host 'Download complete.' -ForegroundColor Green
        }

        Write-Host 'Installing updates (this can take a long time)...' -ForegroundColor Yellow
        Write-Host 'Do not close this window.' -ForegroundColor Yellow
        $installer = $session.CreateUpdateInstaller()
        $installer.Updates = $result.Updates
        $installResult = $installer.Install()

        Write-Host "Install result code: $($installResult.ResultCode)" -ForegroundColor White
        Write-ASULog "Updates install result code: $($installResult.ResultCode)" -Level Info

        Write-Host ''
        Write-Host 'Restarting in 90 seconds so updates can finish applying.' -ForegroundColor Yellow
        Write-Host 'Save work now. To cancel restart, run: shutdown /a' -ForegroundColor Gray
        shutdown.exe /r /t 90 /c "ASU: Restarting to apply Windows updates"
        Write-ASULog 'Restart scheduled after update install' -Level Info
    }
    catch {
        Write-Host "Update install failed: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host 'You can still use Settings > Windows Update, or restart manually later.' -ForegroundColor Yellow
        Write-ASULog "Install/restart failed: $_" -Level Error
    }

    Pause
}

Export-ModuleMember -Function Show-UpdatesMenu, Show-InstallRestartMenu