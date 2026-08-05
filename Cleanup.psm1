<#
.SYNOPSIS
    Cleanup module for ASU
#>

function Show-CleanupMenu {
    Clear-Host
    Write-Host '=== System Cleanup ===' -ForegroundColor Cyan
    Write-Host 'Cleaning temporary files older than 1 day...' -ForegroundColor Yellow

    $tempPath = $env:TEMP
    $cutoff = (Get-Date).AddDays(-1)
    $removed = 0

    Get-ChildItem -Path $tempPath -Recurse -Force -ErrorAction SilentlyContinue |
        Where-Object { -not $_.PSIsContainer -and $_.LastWriteTime -lt $cutoff } |
        ForEach-Object {
            try {
                Remove-Item -LiteralPath $_.FullName -Force -ErrorAction Stop
                $removed++
            }
            catch {
                # Ignore locked or permission-denied files
            }
        }

    Write-Host "Temp files cleaned. Removed approximately $removed items." -ForegroundColor Green
    Write-ASULog "System cleanup performed (removed ~$removed items)" -Level 'Info'
    Pause
    Show-MainMenu
}

Export-ModuleMember -Function Show-CleanupMenu