<#
.SYNOPSIS
    Cleanup module for ASU
#>

function Show-CleanupMenu {
    Clear-Host
    Write-Host '=== System Cleanup ===' -ForegroundColor Cyan
    Write-Host 'This will remove temporary files older than 1 day from:' -ForegroundColor Yellow
    Write-Host '  - User TEMP' -ForegroundColor Gray
    Write-Host '  - Windows TEMP' -ForegroundColor Gray
    Write-Host ''

    if (-not (Test-AdminRights)) {
        Write-Host 'Administrator rights recommended for full cleanup.' -ForegroundColor Yellow
    }

    $confirm = Read-Host 'Continue? (Y/N)'
    if ($confirm -notmatch '^[Yy]') {
        Write-Host 'Cancelled.' -ForegroundColor Yellow
        Pause
        return
    }

    $cutoff = (Get-Date).AddDays(-1)
    $removed = 0
    $paths = @(
        $env:TEMP,
        "$env:SystemRoot\Temp"
    )

    foreach ($p in $paths) {
        if (-not (Test-Path $p)) { continue }
        Get-ChildItem -Path $p -Recurse -Force -ErrorAction SilentlyContinue |
            Where-Object { -not $_.PSIsContainer -and $_.LastWriteTime -lt $cutoff } |
            ForEach-Object {
                try {
                    Remove-Item -LiteralPath $_.FullName -Force -ErrorAction Stop
                    $removed++
                } catch {}
            }
    }

    Write-Host "Cleanup finished. Removed approximately $removed files." -ForegroundColor Green
    Write-ASULog "Cleanup removed ~$removed files" -Level Info
    Pause
}

Export-ModuleMember -Function Show-CleanupMenu