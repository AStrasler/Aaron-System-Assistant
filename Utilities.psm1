<#
.SYNOPSIS
    Utilities helper module.

.DESCRIPTION
    Provides lightweight helper views for available utility scripts and quick
    actions to inspect the `tools` folder. This replaces previous deprecated
    behavior and surfaces available utilities to the user.
#>

<#
.SYNOPSIS
    Show-UtilitiesMenu (auto-added help)
#>
function Show-UtilitiesMenu {
    Clear-Host
    Write-Host "=== Utilities ===" -ForegroundColor Cyan
    $toolsPath = Join-Path -Path $PSScriptRoot -ChildPath '..\tools'
    if (Test-Path $toolsPath) {
        Write-Host "Available helper scripts in tools/:" -ForegroundColor Yellow
        Get-ChildItem -Path $toolsPath -Filter '*.ps1' -File | Select-Object Name, Length | Format-Table -AutoSize
    } else {
        Write-Host "No tools folder found." -ForegroundColor Yellow
    }
    Write-ASULog "Utilities menu displayed" -Level "Info"
    Pause
    Show-MainMenu
}

function Get-UtilitiesList {
    param()
    $toolsPath = Join-Path -Path $PSScriptRoot -ChildPath '..\tools'
    if (Test-Path $toolsPath) {
        return Get-ChildItem -Path $toolsPath -Filter '*.ps1' -File | Select-Object Name, Length
    } else {
        return @()
    }
}

Export-ModuleMember -Function Show-UtilitiesMenu,Get-UtilitiesList



