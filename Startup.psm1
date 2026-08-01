<# 
.SYNOPSIS
    Startup management module for ASU
#>

function Show-StartupMenu {
    Clear-Host
    Write-Host "=== Startup Applications ===" -ForegroundColor Cyan
    Get-CimInstance Win32_StartupCommand | Select-Object Name, Command, Location | Format-Table -AutoSize
    Write-Host "`nNote: Use Task Manager or msconfig for management in this version." -ForegroundColor Yellow
    Write-ASULog "Startup items viewed" -Level "Info"
    Pause
    Show-MainMenu
}

Export-ModuleMember -Function Show-StartupMenu