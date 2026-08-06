# Utilities.psm1 — Core helpers for ASA

function Test-AdminRights {
    $identity  = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($identity)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Request-Elevation {
    if (Test-AdminRights) { return $true }

    Write-Host '  This action requires Administrator privileges.' -ForegroundColor Yellow
    $answer = Read-Host '  Re-launch ASA as Administrator? (Y/N)'
    if ($answer -notmatch '^[Yy]') {
        Write-Host '  Cancelled.' -ForegroundColor Yellow
        return $true
    }

    $scriptPath = Join-Path $global:ScriptPath 'ASA.ps1'
    Start-Process -FilePath 'powershell.exe' -ArgumentList @(
        '-NoProfile',
        '-ExecutionPolicy', 'Bypass',
        '-File', "`"$scriptPath`""
    ) -Verb RunAs

    Write-Host '  Elevated instance started. You can close this window.' -ForegroundColor Green
    return $false
}

function Set-ASAConsoleTheme {
    $appsUseLight = 1
    try {
        $key = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize'
        $props = Get-ItemProperty -Path $key -ErrorAction Stop
        if ($null -ne $props.AppsUseLightTheme) {
            $appsUseLight = $props.AppsUseLightTheme
        }
        elseif ($null -ne $props.SystemUsesLightTheme) {
            $appsUseLight = $props.SystemUsesLightTheme
        }
    } catch {}

    if ($appsUseLight -eq 1) {
        $theme = [pscustomobject]@{
            Name          = 'Light'
            Title         = 'DarkCyan'
            Muted         = 'DarkGray'
            Normal        = 'Black'
            MenuItem      = 'DarkGreen'
            MenuHighlight = 'DarkCyan'
            Warning       = 'DarkYellow'
            Error         = 'DarkRed'
            Success       = 'DarkGreen'
        }
        try {
            $Host.UI.RawUI.BackgroundColor = 'White'
            $Host.UI.RawUI.ForegroundColor = 'Black'
            Clear-Host
        } catch {}
    }
    else {
        $theme = [pscustomobject]@{
            Name          = 'Dark'
            Title         = 'Cyan'
            Muted         = 'DarkGray'
            Normal        = 'Gray'
            MenuItem      = 'Green'
            MenuHighlight = 'Cyan'
            Warning       = 'Yellow'
            Error         = 'Red'
            Success       = 'Green'
        }
        try {
            $Host.UI.RawUI.BackgroundColor = 'Black'
            $Host.UI.RawUI.ForegroundColor = 'Gray'
            Clear-Host
        } catch {}
    }

    return $theme
}

Export-ModuleMember -Function Test-AdminRights, Request-Elevation, Set-ASAConsoleTheme