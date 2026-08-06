<#
.SYNOPSIS
    Cleanup module for ASA
#>

function Show-CleanupMenu {
    Clear-Host
    Write-Host "`n  🧹 System Cleanup" -ForegroundColor Cyan
    Write-Host "  ─────────────────" -ForegroundColor Gray
    Write-Host "  Removes temporary files older than 1 day from:" -ForegroundColor Yellow
    Write-Host "    - User TEMP" -ForegroundColor Gray
    Write-Host "    - Windows TEMP" -ForegroundColor Gray
    Write-Host ""

    # Check admin rights — if missing, warn but still allow (may skip Windows TEMP)
    $isAdmin = Test-AdminRights
    if (-not $isAdmin) {
        Write-Host "  ⚠️ Not running as Administrator. Windows TEMP may be skipped." -ForegroundColor Yellow
        Write-Host "  💡 Run as Admin for full cleanup." -ForegroundColor Gray
        Write-Host ""
    }

    $confirm = Read-Host "  Continue? (Y/N)"
    if ($confirm -notmatch '^[Yy]') {
        Write-Host "  Cancelled." -ForegroundColor Yellow
        Pause
        return
    }

    Write-Host "`n  🔍 Scanning for files older than 1 day..." -ForegroundColor Gray

    $cutoff = (Get-Date).AddDays(-1)
    $removed = 0
    $totalSize = 0
    $paths = @($env:TEMP)

    # Add Windows TEMP only if admin
    if ($isAdmin) {
        $paths += "$env:SystemRoot\Temp"
    }

    foreach ($p in $paths) {
        if (-not (Test-Path $p)) { continue }

        $files = Get-ChildItem -Path $p -Recurse -Force -ErrorAction SilentlyContinue |
            Where-Object { -not $_.PSIsContainer -and $_.LastWriteTime -lt $cutoff }

        foreach ($file in $files) {
            try {
                $size = $file.Length
                Remove-Item -LiteralPath $file.FullName -Force -ErrorAction Stop
                $removed++
                $totalSize += $size
            } catch {
                # File may be in use — skip silently
            }
        }
    }

    # Format size in MB or GB
    $sizeMB = [math]::Round($totalSize / 1MB, 2)
    $sizeGB = [math]::Round($totalSize / 1GB, 2)
    $sizeDisplay = if ($totalSize -gt 1GB) { "$sizeGB GB" } else { "$sizeMB MB" }

    Write-Host "`n  ✅ Cleanup finished." -ForegroundColor Green
    Write-Host "     Removed $removed files ($sizeDisplay)" -ForegroundColor Gray
    Write-ASALog "Cleanup removed $removed files ($sizeDisplay)" -Level Info
    Pause
}

Export-ModuleMember -Function Show-CleanupMenu