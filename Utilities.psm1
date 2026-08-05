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

Export-ModuleMember -Function Test-AdminRights, Request-Elevation