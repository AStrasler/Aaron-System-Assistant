<#
.SYNOPSIS
    Startup management module for ASU
#>

<#
.SYNOPSIS
    Display startup applications and related notes.

.DESCRIPTION
    Lists startup commands and suggests management tools for modification.

.EXAMPLE
    Show-StartupMenu
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

function Get-StartupItems {
    param()
    $items = Get-CimInstance Win32_StartupCommand | Select-Object Name, Command, Location
    return $items
}

Export-ModuleMember -Function Show-StartupMenu,Get-StartupItems



