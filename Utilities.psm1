<#
.SYNOPSIS
    Shared utility functions for ASU
#>

function Test-AdminRights {
    $identity  = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($identity)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Request-Elevation {
    if (Test-AdminRights) { return $true }

    Write-Host 'This action requires Administrator privileges.' -ForegroundColor Yellow
    $answer = Read-Host 'Re-launch ASU as Administrator? (Y/N)'
    if ($answer -notmatch '^[Yy]') {
        Write-Host 'Cancelled.' -ForegroundColor Yellow
        return $true
    }

    $scriptPath = Join-Path $global:ScriptPath 'ASU.ps1'
    Start-Process -FilePath 'powershell.exe' -ArgumentList @(
        '-NoProfile',
        '-ExecutionPolicy', 'Bypass',
        '-File', "`"$scriptPath`""
    ) -Verb RunAs

    Write-Host 'Elevated instance started. You can close this window.' -ForegroundColor Green
    return $false
}

function Get-ASUTheme {
    $appsUseLight = 1
    try {
        $appsUseLight = (Get-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize' -Name 'AppsUseLightTheme' -ErrorAction Stop).AppsUseLightTheme
    } catch {}

    if ($appsUseLight -eq 1) {
        return [pscustomobject]@{
            Name          = 'Light'
            Title         = 'DarkCyan'
            MenuItem      = 'DarkGreen'
            MenuHighlight = 'DarkCyan'
            Warning       = 'DarkYellow'
            Error         = 'DarkRed'
            Success       = 'DarkGreen'
            Muted         = 'DarkGray'
            Normal        = 'Black'
        }
    }
    else {
        return [pscustomobject]@{
            Name          = 'Dark'
            Title         = 'Cyan'
            MenuItem      = 'Green'
            MenuHighlight = 'Cyan'
            Warning       = 'Yellow'
            Error         = 'Red'
            Success       = 'Green'
            Muted         = 'DarkGray'
            Normal        = 'Gray'
        }
    }
}

function Set-ASUConsoleTheme {
    $theme = Get-ASUTheme
    try {
        if ($theme.Name -eq 'Light') {
            $Host.UI.RawUI.BackgroundColor = 'White'
            $Host.UI.RawUI.ForegroundColor = 'Black'
        }
        else {
            $Host.UI.RawUI.BackgroundColor = 'Black'
            $Host.UI.RawUI.ForegroundColor = 'Gray'
        }
        Clear-Host
    } catch {}
    return $theme
}

Export-ModuleMember -Function Test-AdminRights, Request-Elevation, Get-ASUTheme, Set-ASUConsoleTheme