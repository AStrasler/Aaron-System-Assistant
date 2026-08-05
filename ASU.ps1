#Requires -Version 5.1

<#
.SYNOPSIS
    Aaron System Utility (ASU) - Main launcher
.NOTES
    Portable. Version read from VERSION file.
    Modules auto-discovered. LoggingLevel respected.
    Console theme follows Windows light/dark mode.
#>

$script:ScriptPath = Split-Path -Parent $MyInvocation.MyCommand.Definition
$global:ScriptPath = $script:ScriptPath
Set-Location -Path $script:ScriptPath -ErrorAction SilentlyContinue

# Version
$versionFile = Join-Path $script:ScriptPath 'VERSION'
$script:ASUVersion = if (Test-Path $versionFile) {
    (Get-Content $versionFile -Raw).Trim()
} else { '1.0.1' }

# Settings
$settingsPath = Join-Path $script:ScriptPath 'settings.json'
if (Test-Path $settingsPath) {
    $script:Config = Get-Content $settingsPath -Raw | ConvertFrom-Json
} else {
    $script:Config = [pscustomobject]@{
        LoggingLevel     = 'Info'
        ReportPath       = 'Reports'
        HealthThresholds = [pscustomobject]@{
            MemoryWarning  = 80
            StorageWarning = 20
            BatteryWarning = 70
        }
    }
}

# Load Utilities first (required for theme + admin helpers)
$utilitiesPath = Join-Path $script:ScriptPath 'Utilities.psm1'
if (Test-Path $utilitiesPath) {
    Import-Module $utilitiesPath -Force -ErrorAction SilentlyContinue
}

# Apply theme early
$script:Theme = Set-ASUConsoleTheme

function Write-ASULog {
    param(
        [Parameter(Mandatory)][string]$Message,
        [ValidateSet('Info','Warning','Error','Debug')][string]$Level = 'Info'
    )
    $levelOrder = @{ Debug = 0; Info = 1; Warning = 2; Error = 3 }
    $configLevel = $script:Config.LoggingLevel
    if (-not $levelOrder.ContainsKey($configLevel)) { $configLevel = 'Info' }
    if ($levelOrder[$Level] -lt $levelOrder[$configLevel]) { return }

    $t = $script:Theme
    $ts = Get-Date -Format 'HH:mm:ss'
    $color = switch ($Level) {
        'Error'   { $t.Error }
        'Warning' { $t.Warning }
        'Info'    { $t.Success }
        'Debug'   { $t.Muted }
        default   { $t.Normal }
    }
    Write-Host "  [$ts] $Message" -ForegroundColor $color

    $logDir = Join-Path $script:ScriptPath 'Logs'
    if (-not (Test-Path $logDir)) { New-Item -Path $logDir -ItemType Directory -Force | Out-Null }
    $logFile = Join-Path $logDir ("ASU_{0}.log" -f (Get-Date -Format 'yyyy-MM-dd'))
    "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') [$Level] $Message" | Add-Content -Path $logFile -Encoding UTF8 -ErrorAction SilentlyContinue
}

function Pause {
    Write-Host ''
    Write-Host '  Press any key to continue...' -ForegroundColor $script:Theme.Muted
    $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
}

# Auto-discover remaining modules
$script:MenuItems = [System.Collections.Generic.List[object]]::new()

Get-ChildItem -Path $script:ScriptPath -Filter '*.psm1' -File |
    Where-Object { $_.Name -ne 'Utilities.psm1' } |
    ForEach-Object {
        try {
            Import-Module $_.FullName -Force -ErrorAction Stop
            Write-ASULog "Loaded module: $($_.BaseName)" -Level Debug
        } catch {
            Write-ASULog "Failed to load $($_.Name): $_" -Level Error
        }
    }

# Friendly names for known menus
$menuMap = [ordered]@{
    'Show-BatteryMenu'       = 'Battery Management'
    'Show-CleanupMenu'       = 'Cleanup Utilities'
    'Show-MemoryMenu'        = 'Memory Management'
    'Show-NetworkMenu'       = 'Network Tools'
    'Show-StorageMenu'       = 'Storage Management'
    'Show-UpdatesMenu'       = 'Updates'
    'Show-StartupMenu'       = 'Startup Applications'
    'Show-WindowsRepairMenu' = 'Windows Repair'
    'Show-ReportsMenu'       = 'Generate Reports'
}

$index = 1
foreach ($cmdName in $menuMap.Keys) {
    if (Get-Command $cmdName -ErrorAction SilentlyContinue) {
        $script:MenuItems.Add([pscustomobject]@{
            Index   = $index
            Name    = $menuMap[$cmdName]
            Command = $cmdName
        })
        $index++
    }
}

[Console]::Title = "Aaron System Utility v$($script:ASUVersion)"

function Show-About {
    Clear-Host
    $t = $script:Theme

    Write-Host ''
    Write-Host '  Aaron System Utility' -ForegroundColor $t.Title
    Write-Host "  v$($script:ASUVersion)" -ForegroundColor $t.Muted
    Write-Host ''
    Write-Host '  ────────────────────────────────────' -ForegroundColor $t.Muted
    Write-Host ''
    Write-Host "  Path       $($script:ScriptPath)" -ForegroundColor $t.Normal
    Write-Host "  Admin      $(if (Test-AdminRights) {'Yes'} else {'No'})" -ForegroundColor $t.Normal
    Write-Host "  Theme      $($t.Name)" -ForegroundColor $t.Normal
    Write-Host "  Log Level  $($script:Config.LoggingLevel)" -ForegroundColor $t.Normal
    Write-Host "  Modules    $($script:MenuItems.Count) loaded" -ForegroundColor $t.Normal
    Write-Host ''
    Write-Host '  Portable Windows maintenance tool.' -ForegroundColor $t.Muted
    Write-Host '  Destructive actions always ask for confirmation.' -ForegroundColor $t.Muted
    Write-Host ''
    Pause
}

function Show-MainMenu {
    Clear-Host
    $t = $script:Theme

    Write-Host ''
    Write-Host '  Aaron System Utility' -ForegroundColor $t.Title
    Write-Host "  v$($script:ASUVersion)" -ForegroundColor $t.Muted
    Write-Host ''
    Write-Host '  ────────────────────────────────────' -ForegroundColor $t.Muted
    Write-Host ''

    if (-not (Test-AdminRights)) {
        Write-Host '  Not running as Administrator' -ForegroundColor $t.Warning
        Write-Host '  Repair / Cleanup can elevate when needed' -ForegroundColor $t.Muted
        Write-Host ''
    }

    foreach ($item in $script:MenuItems) {
        Write-Host ("  {0}  {1}" -f $item.Index, $item.Name) -ForegroundColor $t.MenuItem
    }

    Write-Host ''
    Write-Host '  A  About / Help' -ForegroundColor $t.MenuHighlight
    Write-Host '  0  Exit' -ForegroundColor $t.Error
    Write-Host ''
}

Write-ASULog "ASU v$($script:ASUVersion) starting" -Level Info

do {
    Show-MainMenu
    $choice = Read-Host '  Choice'

    if ($choice -eq '0') {
        Write-Host ''
        Write-Host '  Exiting ASU. Goodbye!' -ForegroundColor $script:Theme.Warning
        Write-ASULog 'ASU exited by user' -Level Info
        exit 0
    }
    if ($choice -match '^[Aa]$') {
        Show-About
        continue
    }

    $selected = $script:MenuItems | Where-Object { $_.Index -eq [int]$choice } | Select-Object -First 1
    if (-not $selected) {
        Write-Host '  Invalid choice.' -ForegroundColor $script:Theme.Error
        Start-Sleep -Seconds 1
        continue
    }

    try {
        & $selected.Command
    } catch {
        Write-Host "  Error in $($selected.Name): $($_.Exception.Message)" -ForegroundColor $script:Theme.Error
        Write-ASULog "Error in $($selected.Command): $_" -Level Error
        Pause
    }
} while ($true)