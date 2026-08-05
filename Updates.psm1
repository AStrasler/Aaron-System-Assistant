<#
.SYNOPSIS
    Updates module for ASU
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
            $SearchResult.Updates | Select-Object -First 5 | ForEach-Object {
                Write-Host " - $($_.Title)" -ForegroundColor Gray
            }
        }
    }
    catch {
        Write-Host 'Unable to query Windows Update COM interface. Use Settings > Windows Update instead.' -ForegroundColor Yellow
        Write-ASULog "Windows Update check failed: $_" -Level 'Warning'
    }

    Write-ASULog 'Updates check performed' -Level 'Info'
    Pause
    Show-MainMenu
}

Export-ModuleMember -Function Show-UpdatesMenu