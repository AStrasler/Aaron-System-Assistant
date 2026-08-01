#Requires -RunAsAdministrator

<#
.SYNOPSIS
    Aaron System Utility (ASU) - Main launcher script
.DESCRIPTION
    Central hub for system utilities including battery, cleanup, memory, network, storage, updates, and Windows repair
#>

# PSScriptAnalyzerSuppressMessage -RuleName PSAvoidUsingWriteHost -Justification 'Interactive console output intentional for menu UI'
# PSScriptAnalyzerSuppressMessage -RuleName PSAvoidGlobalVars -Justification 'Global config is intentionally provided to modules by ASU.ps1 for interactive utility context'
# Get the script directory
$ScriptPath = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition

# Import config accessor module (loads config.json for the repo)
Import-Module "$ScriptPath\Config.psm1" -Force

# Import all modules
Import-Module "$ScriptPath\Battery.psm1" -Force
Import-Module "$ScriptPath\Cleanup.psm1" -Force
Import-Module "$ScriptPath\Memory.psm1" -Force
Import-Module "$ScriptPath\Network.psm1" -Force
Import-Module "$ScriptPath\Startup.psm1" -Force
Import-Module "$ScriptPath\Storage.psm1" -Force
Import-Module "$ScriptPath\Updates.psm1" -Force
Import-Module "$ScriptPath\Utilities.psm1" -Force
Import-Module "$ScriptPath\WindowsRepair.psm1" -Force
Import-Module "$ScriptPath\Reports.psm1" -Force

# Set console title
[Console]::Title = "Aaron System Utility"

# Logging function used by all modules
function Write-ASULog {
    param(
        [string]$Message,
        [string]$Level = "Info"
    )
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    # Respect configured logging level (Error > Warning > Info)
    $levelPriority = @{ 'Info' = 1; 'Warning' = 2; 'Error' = 3 }
    $configured = Get-ASULoggingLevel
    $current = if ($configured -and $levelPriority.ContainsKey($configured)) { $levelPriority[$configured] } else { 1 }
    $msgLevel = if ($levelPriority.ContainsKey($Level)) { $levelPriority[$Level] } else { 1 }
    if ($msgLevel -lt $current) { return }

    # Simple console output (no color to remain analyzer-friendly)
    Write-Output "[$Timestamp] [$Level] $Message"
}

# Main Menu Function
<#
.SYNOPSIS
    Main interactive menu for Aaron System Utility.

.DESCRIPTION
    Displays the main menu and routes to individual module menus.

.EXAMPLE
    Show-MainMenu
#>
function Show-MainMenu {
    Clear-Host
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "   AARON SYSTEM UTILITY (ASU)" -ForegroundColor Cyan
    Write-Host "          Main Menu" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "1. Battery Management" -ForegroundColor Green
    Write-Host "2. Cleanup Utilities" -ForegroundColor Green
    Write-Host "3. Memory Management" -ForegroundColor Green
    Write-Host "4. Network Tools" -ForegroundColor Green
    Write-Host "5. Storage Management" -ForegroundColor Green
    Write-Host "6. Updates" -ForegroundColor Green
    Write-Host "7. Startup Applications" -ForegroundColor Green
    Write-Host "8. Windows Repair" -ForegroundColor Green
    Write-Host "9. Generate Reports" -ForegroundColor Green
    Write-Host "0. Exit" -ForegroundColor Red
    Write-Host ""

    $choice = Read-Host "Enter your choice (0-9)"

    switch ($choice) {
        '1' {
            if (Get-Command Show-BatteryMenu -ErrorAction SilentlyContinue) {
                Show-BatteryMenu
            } else {
                Write-Host "Battery module not loaded" -ForegroundColor Red
                Pause
                Show-MainMenu
            }
        }
        '2' {
            if (Get-Command Show-CleanupMenu -ErrorAction SilentlyContinue) {
                Show-CleanupMenu
            } else {
                Write-Host "Cleanup module not loaded" -ForegroundColor Red
                Pause
                Show-MainMenu
            }
        }
        '3' {
            if (Get-Command Show-MemoryMenu -ErrorAction SilentlyContinue) {
                Show-MemoryMenu
            } else {
                Write-Host "Memory module not loaded" -ForegroundColor Red
                Pause
                Show-MainMenu
            }
        }
        '4' {
            if (Get-Command Show-NetworkMenu -ErrorAction SilentlyContinue) {
                Show-NetworkMenu
            } else {
                Write-Host "Network module not loaded" -ForegroundColor Red
                Pause
                Show-MainMenu
            }
        }
        '5' {
            if (Get-Command Show-StorageMenu -ErrorAction SilentlyContinue) {
                Show-StorageMenu
            } else {
                Write-Host "Storage module not loaded" -ForegroundColor Red
                Pause
                Show-MainMenu
            }
        }
        '6' {
            if (Get-Command Show-UpdatesMenu -ErrorAction SilentlyContinue) {
                Show-UpdatesMenu
            } else {
                Write-Host "Updates module not loaded" -ForegroundColor Red
                Pause
                Show-MainMenu
            }
        }
        '7' {
            if (Get-Command Show-StartupMenu -ErrorAction SilentlyContinue) {
                Show-StartupMenu
            } else {
                Write-Host "Startup module not loaded" -ForegroundColor Red
                Pause
                Show-MainMenu
            }
        }
        '8' {
            if (Get-Command Show-WindowsRepairMenu -ErrorAction SilentlyContinue) {
                Show-WindowsRepairMenu
            } else {
                Write-Host "Windows Repair module not loaded" -ForegroundColor Red
                Pause
                Show-MainMenu
            }
        }
        '9' {
            if (Get-Command Show-ReportsMenu -ErrorAction SilentlyContinue) {
                Show-ReportsMenu
            } else {
                Write-Host "Reports module not loaded" -ForegroundColor Red
                Pause
                Show-MainMenu
            }
        }
        '0' {
            Write-Host "Exiting ASU. Goodbye!" -ForegroundColor Yellow
            exit
        }
        default {
            Write-Host "Invalid choice. Please try again." -ForegroundColor Red
            Pause
            Show-MainMenu
        }
    }
}

# Start the utility
Show-MainMenu


