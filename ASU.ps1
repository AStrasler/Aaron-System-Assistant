#Requires -RunAsAdministrator

<#
.SYNOPSIS
    Aaron System Utility (ASU) - Main launcher script
.DESCRIPTION
    Central hub for system utilities including battery, cleanup, memory, network, storage, updates, startup, Windows repair, and reports.
.NOTES
    Version: 1.0.1
    Compatible with PowerShell 5.1 on Windows 10/11
#>

# Get the script directory (must be set before any module use)
$script:ScriptPath = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition
$global:ScriptPath = $script:ScriptPath

# Import all modules (order is intentional: utilities first)
$moduleFiles = @(
    'Utilities.psm1',
    'Battery.psm1',
    'Cleanup.psm1',
    'Memory.psm1',
    'Network.psm1',
    'Storage.psm1',
    'Startup.psm1',
    'Updates.psm1',
    'WindowsRepair.psm1',
    'Reports.psm1'
)

foreach ($mod in $moduleFiles) {
    $modPath = Join-Path $script:ScriptPath $mod
    if (Test-Path $modPath) {
        try {
            Import-Module $modPath -Force -ErrorAction Stop
        }
        catch {
            Write-Host "Failed to import $mod : $_" -ForegroundColor Red
        }
    }
    else {
        Write-Host "Module file missing: $mod" -ForegroundColor Red
    }
}

# Set console title
[Console]::Title = "Aaron System Utility v1.0.1"

# Logging function used by all modules
function Write-ASULog {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Message,
        [ValidateSet('Info', 'Warning', 'Error', 'Debug')]
        [string]$Level = 'Info'
    )
    $Timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'

    # Console output
    $Color = switch ($Level) {
        'Error'   { 'Red' }
        'Warning' { 'Yellow' }
        'Info'    { 'Green' }
        'Debug'   { 'Gray' }
        default   { 'White' }
    }
    Write-Host "[$Timestamp] [$Level] $Message" -ForegroundColor $Color

    # File logging
    $logDir = Join-Path $script:ScriptPath 'Logs'
    if (-not (Test-Path $logDir)) {
        New-Item -Path $logDir -ItemType Directory -Force | Out-Null
    }
    $logFile = Join-Path $logDir ("ASU_{0}.log" -f (Get-Date -Format 'yyyy-MM-dd'))
    "$Timestamp [$Level] $Message" | Add-Content -Path $logFile -Encoding UTF8 -ErrorAction SilentlyContinue
}

# Shared pause helper (required by every module)
function Pause {
    Write-Host "`nPress any key to continue..." -ForegroundColor DarkGray
    $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
}

# Main Menu Function
function Show-MainMenu {
    Clear-Host
    Write-Host '========================================' -ForegroundColor Cyan
    Write-Host '   AARON SYSTEM UTILITY (ASU) v1.0.1' -ForegroundColor Cyan
    Write-Host '          Main Menu' -ForegroundColor Cyan
    Write-Host '========================================' -ForegroundColor Cyan
    Write-Host ''
    Write-Host '1. Battery Management' -ForegroundColor Green
    Write-Host '2. Cleanup Utilities' -ForegroundColor Green
    Write-Host '3. Memory Management' -ForegroundColor Green
    Write-Host '4. Network Tools' -ForegroundColor Green
    Write-Host '5. Storage Management' -ForegroundColor Green
    Write-Host '6. Updates' -ForegroundColor Green
    Write-Host '7. Startup Applications' -ForegroundColor Green
    Write-Host '8. Windows Repair' -ForegroundColor Green
    Write-Host '9. Generate Reports' -ForegroundColor Green
    Write-Host '0. Exit' -ForegroundColor Red
    Write-Host ''

    $choice = Read-Host 'Enter your choice (0-9)'

    switch ($choice) {
        '1' {
            if (Get-Command Show-BatteryMenu -ErrorAction SilentlyContinue) {
                Show-BatteryMenu
            }
            else {
                Write-Host 'Battery module not loaded' -ForegroundColor Red
                Pause
                Show-MainMenu
            }
        }
        '2' {
            if (Get-Command Show-CleanupMenu -ErrorAction SilentlyContinue) {
                Show-CleanupMenu
            }
            else {
                Write-Host 'Cleanup module not loaded' -ForegroundColor Red
                Pause
                Show-MainMenu
            }
        }
        '3' {
            if (Get-Command Show-MemoryMenu -ErrorAction SilentlyContinue) {
                Show-MemoryMenu
            }
            else {
                Write-Host 'Memory module not loaded' -ForegroundColor Red
                Pause
                Show-MainMenu
            }
        }
        '4' {
            if (Get-Command Show-NetworkMenu -ErrorAction SilentlyContinue) {
                Show-NetworkMenu
            }
            else {
                Write-Host 'Network module not loaded' -ForegroundColor Red
                Pause
                Show-MainMenu
            }
        }
        '5' {
            if (Get-Command Show-StorageMenu -ErrorAction SilentlyContinue) {
                Show-StorageMenu
            }
            else {
                Write-Host 'Storage module not loaded' -ForegroundColor Red
                Pause
                Show-MainMenu
            }
        }
        '6' {
            if (Get-Command Show-UpdatesMenu -ErrorAction SilentlyContinue) {
                Show-UpdatesMenu
            }
            else {
                Write-Host 'Updates module not loaded' -ForegroundColor Red
                Pause
                Show-MainMenu
            }
        }
        '7' {
            if (Get-Command Show-StartupMenu -ErrorAction SilentlyContinue) {
                Show-StartupMenu
            }
            else {
                Write-Host 'Startup module not loaded' -ForegroundColor Red
                Pause
                Show-MainMenu
            }
        }
        '8' {
            if (Get-Command Show-WindowsRepairMenu -ErrorAction SilentlyContinue) {
                Show-WindowsRepairMenu
            }
            else {
                Write-Host 'Windows Repair module not loaded' -ForegroundColor Red
                Pause
                Show-MainMenu
            }
        }
        '9' {
            if (Get-Command Show-ReportsMenu -ErrorAction SilentlyContinue) {
                Show-ReportsMenu
            }
            else {
                Write-Host 'Reports module not loaded' -ForegroundColor Red
                Pause
                Show-MainMenu
            }
        }
        '0' {
            Write-Host 'Exiting ASU. Goodbye!' -ForegroundColor Yellow
            Write-ASULog 'ASU exited by user' -Level 'Info'
            exit 0
        }
        default {
            Write-Host 'Invalid choice. Please try again.' -ForegroundColor Red
            Pause
            Show-MainMenu
        }
    }
}

# Start the utility
Write-ASULog 'ASU starting up' -Level 'Info'
Show-MainMenu