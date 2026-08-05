#Requires -Version 5.1

<#
.SYNOPSIS
    Aaron System Utility (ASU) - Main launcher
.NOTES
    Version is read from the VERSION file
#>

$script:ScriptPath = Split-Path -Parent $MyInvocation.MyCommand.Definition
$global:ScriptPath = $script:ScriptPath

# Read version
$versionFile = Join-Path $script:ScriptPath 'VERSION'
$script:ASUVersion = if (Test-Path $versionFile) { (Get-Content $versionFile -Raw).Trim() } else { '1.0.1' }

# Load settings
$settingsPath = Join-Path $script:ScriptPath 'settings.json'
if (Test-Path $settingsPath) {
    $script:Config = Get-Content $settingsPath -Raw | ConvertFrom-Json
} else {
    $script:Config = [pscustomobject]@{
        LoggingLevel = 'Info'
        ReportPath   = 'Reports'
        HealthThresholds = [pscustomobject]@{
            MemoryWarning  = 80
            StorageWarning = 20
            BatteryWarning = 70
        }
    }
}

# Import modules
$moduleFiles = @(
    'Utilities.psm1', 'Battery.psm1', 'Cleanup.psm1', 'Memory.psm1',
    'Network.psm1', 'Storage.psm1', 'Startup.psm1', 'Updates.psm1',
    'WindowsRepair.psm1', 'Reports.psm1'
)

foreach ($mod in $moduleFiles) {
    $modPath = Join-Path $script:ScriptPath $mod
    if (Test-Path $modPath) {
        try { Import-Module $modPath -Force -ErrorAction Stop }
        catch { Write-Host "Failed to import $mod : $_" -ForegroundColor Red }
    }
}

[Console]::Title = "Aaron System Utility v$($script:ASUVersion)"

function Write-ASULog {
    param(
        [Parameter(Mandatory)][string]$Message,
        [ValidateSet('Info','Warning','Error','Debug')][string]$Level = 'Info'
    )
    $ts = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    $color = switch ($Level) {
        'Error'   { 'Red' }
        'Warning' { 'Yellow' }
        'Info'    { 'Green' }
        'Debug'   { 'Gray' }
        default   { 'White' }
    }
    Write-Host "[$ts] [$Level] $Message" -ForegroundColor $color

    $logDir = Join-Path $script:ScriptPath 'Logs'
    if (-not (Test-Path $logDir)) { New-Item -Path $logDir -ItemType Directory -Force | Out-Null }
    $logFile = Join-Path $logDir ("ASU_{0}.log" -f (Get-Date -Format 'yyyy-MM-dd'))
    "$ts [$Level] $Message" | Add-Content -Path $logFile -Encoding UTF8 -ErrorAction SilentlyContinue
}

function Pause {
    Write-Host "`nPress any key to continue..." -ForegroundColor DarkGray
    $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
}

function Show-MainMenu {
    Clear-Host
    Write-Host '========================================' -ForegroundColor Cyan
    Write-Host "   AARON SYSTEM UTILITY (ASU) v$($script:ASUVersion)" -ForegroundColor Cyan
    Write-Host '========================================' -ForegroundColor Cyan
    Write-Host ''

    $isAdmin = Test-AdminRights
    if (-not $isAdmin) {
        Write-Host 'Running without Administrator privileges.' -ForegroundColor Yellow
        Write-Host 'Some repair and cleanup actions will be blocked.' -ForegroundColor Yellow
        Write-Host ''
    }

    Write-Host '1. Battery Management'     -ForegroundColor Green
    Write-Host '2. Cleanup Utilities'      -ForegroundColor Green
    Write-Host '3. Memory Management'      -ForegroundColor Green
    Write-Host '4. Network Tools'          -ForegroundColor Green
    Write-Host '5. Storage Management'     -ForegroundColor Green
    Write-Host '6. Updates'                -ForegroundColor Green
    Write-Host '7. Startup Applications'   -ForegroundColor Green
    Write-Host '8. Windows Repair'         -ForegroundColor Green
    Write-Host '9. Generate Reports'       -ForegroundColor Green
    Write-Host '0. Exit'                   -ForegroundColor Red
    Write-Host ''
}

# Main loop — no recursion
Write-ASULog "ASU v$($script:ASUVersion) starting" -Level Info

do {
    Show-MainMenu
    $choice = Read-Host 'Enter your choice (0-9)'

    switch ($choice) {
        '1' { if (Get-Command Show-BatteryMenu -EA SilentlyContinue) { Show-BatteryMenu } else { Write-Host 'Battery module missing' -ForegroundColor Red; Pause } }
        '2' { if (Get-Command Show-CleanupMenu -EA SilentlyContinue) { Show-CleanupMenu } else { Write-Host 'Cleanup module missing' -ForegroundColor Red; Pause } }
        '3' { if (Get-Command Show-MemoryMenu -EA SilentlyContinue) { Show-MemoryMenu } else { Write-Host 'Memory module missing' -ForegroundColor Red; Pause } }
        '4' { if (Get-Command Show-NetworkMenu -EA SilentlyContinue) { Show-NetworkMenu } else { Write-Host 'Network module missing' -ForegroundColor Red; Pause } }
        '5' { if (Get-Command Show-StorageMenu -EA SilentlyContinue) { Show-StorageMenu } else { Write-Host 'Storage module missing' -ForegroundColor Red; Pause } }
        '6' { if (Get-Command Show-UpdatesMenu -EA SilentlyContinue) { Show-UpdatesMenu } else { Write-Host 'Updates module missing' -ForegroundColor Red; Pause } }
        '7' { if (Get-Command Show-StartupMenu -EA SilentlyContinue) { Show-StartupMenu } else { Write-Host 'Startup module missing' -ForegroundColor Red; Pause } }
        '8' { if (Get-Command Show-WindowsRepairMenu -EA SilentlyContinue) { Show-WindowsRepairMenu } else { Write-Host 'Windows Repair module missing' -ForegroundColor Red; Pause } }
        '9' { if (Get-Command Show-ReportsMenu -EA SilentlyContinue) { Show-ReportsMenu } else { Write-Host 'Reports module missing' -ForegroundColor Red; Pause } }
        '0' {
            Write-Host 'Exiting ASU. Goodbye!' -ForegroundColor Yellow
            Write-ASULog 'ASU exited by user' -Level Info
            exit 0
        }
        default {
            Write-Host 'Invalid choice.' -ForegroundColor Red
            Start-Sleep -Seconds 1
        }
    }
} while ($true)