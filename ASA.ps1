#Requires -Version 5.1

<#
.SYNOPSIS
    Aaron System Assistant (ASA) - Main launcher
.NOTES
    Portable. Version from VERSION file.
    Menu numbers and natural-language intents both supported.
#>

$script:ScriptPath = Split-Path -Parent $MyInvocation.MyCommand.Definition
$global:ScriptPath = $script:ScriptPath
Set-Location -Path $script:ScriptPath -ErrorAction SilentlyContinue

$versionFile = Join-Path $script:ScriptPath 'VERSION'
$script:ASAVersion = if (Test-Path $versionFile) {
    (Get-Content $versionFile -Raw).Trim()
} else {
    '2.0.0-dev'
}

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

$utilitiesPath = Join-Path $script:ScriptPath 'Utilities.psm1'
if (Test-Path $utilitiesPath) {
    Import-Module $utilitiesPath -Force -ErrorAction SilentlyContinue
}

$licensingPath = Join-Path $script:ScriptPath 'LicenseCheck.psm1'
if (Test-Path $licensingPath) {
    Import-Module $licensingPath -Force -ErrorAction SilentlyContinue
    if (Get-Command Test-ASALicense -ErrorAction SilentlyContinue) {
        if (-not (Test-ASALicense)) { exit 1 }
    }
}

$script:Theme = Set-ASAConsoleTheme

function Write-ASALog {
    param(
        [Parameter(Mandatory)][string]$Message,
        [ValidateSet('Info', 'Warning', 'Error', 'Debug')][string]$Level = 'Info'
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
    if (-not (Test-Path $logDir)) {
        New-Item -Path $logDir -ItemType Directory -Force | Out-Null
    }
    $logFile = Join-Path $logDir ("ASA_{0}.log" -f (Get-Date -Format 'yyyy-MM-dd'))
    "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') [$Level] $Message" |
        Add-Content -Path $logFile -Encoding UTF8 -ErrorAction SilentlyContinue
}

# Backward-compatible alias for any module still calling Write-ASULog
function Write-ASULog {
    param(
        [Parameter(Mandatory)][string]$Message,
        [ValidateSet('Info', 'Warning', 'Error', 'Debug')][string]$Level = 'Info'
    )
    Write-ASALog -Message $Message -Level $Level
}

function Pause {
    Write-Host ''
    Write-Host '  Press any key to continue...' -ForegroundColor $script:Theme.Muted
    $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
}

Get-ChildItem -Path $script:ScriptPath -Filter '*.psm1' -File |
    Where-Object {
        $_.Name -notin @('Utilities.psm1', 'LicenseCheck.psm1')
    } |
    ForEach-Object {
        try {
            Import-Module $_.FullName -Force -ErrorAction Stop
            Write-ASALog "Loaded module: $($_.BaseName)" -Level Debug
        }
        catch {
            Write-ASALog "Failed to load $($_.Name): $_" -Level Error
        }
    }

$menuMap = [ordered]@{
    'Show-BatteryMenu'        = 'Battery Management'
    'Show-CleanupMenu'        = 'Cleanup Utilities'
    'Show-MemoryMenu'         = 'Memory Management'
    'Show-NetworkMenu'        = 'Network Tools'
    'Show-StorageMenu'        = 'Storage Management'
    'Show-UpdatesMenu'        = 'Updates'
    'Show-StartupMenu'        = 'Startup Applications'
    'Show-WindowsRepairMenu'  = 'Windows Repair'
    'Show-ReportsMenu'        = 'Generate Reports'
    'Show-InstallRestartMenu' = 'Install Updates & Restart'
}

$script:MenuItems = [System.Collections.Generic.List[object]]::new()
$index = 1
foreach ($functionName in $menuMap.Keys) {
    if (Get-Command -Name $functionName -ErrorAction SilentlyContinue) {
        $script:MenuItems.Add([pscustomobject]@{
            Index   = $index
            Name    = $menuMap[$functionName]
            Command = $functionName
        })
        $index++
    }
}

[Console]::Title = "Aaron System Assistant v$($script:ASAVersion)"

function Show-About {
    Clear-Host
    $t = $script:Theme
    Write-Host ''
    Write-Host '  Aaron System Assistant' -ForegroundColor $t.Title
    Write-Host "  v$($script:ASAVersion)" -ForegroundColor $t.Muted
    Write-Host ''
    Write-Host '  ────────────────────────────────────' -ForegroundColor $t.Muted
    Write-Host ''
    Write-Host "  Path       $($script:ScriptPath)" -ForegroundColor $t.Normal
    Write-Host "  Admin      $(if (Test-AdminRights) { 'Yes' } else { 'No' })" -ForegroundColor $t.Normal
    Write-Host "  Theme      $($t.Name)" -ForegroundColor $t.Normal
    Write-Host "  Log Level  $($script:Config.LoggingLevel)" -ForegroundColor $t.Normal
    Write-Host "  Modules    $($script:MenuItems.Count) loaded" -ForegroundColor $t.Normal
    Write-Host ''
    Write-Host '  Your PC, now with a brain.' -ForegroundColor $t.Muted
    Write-Host '  Type a menu number or a plain-English request.' -ForegroundColor $t.Muted
    Write-Host '  Destructive actions always ask for confirmation.' -ForegroundColor $t.Muted
    Write-Host ''
    Pause
}

function Show-MainMenu {
    Clear-Host
    $t = $script:Theme
    Write-Host ''
    Write-Host '  Aaron System Assistant' -ForegroundColor $t.Title
    Write-Host "  v$($script:ASAVersion)" -ForegroundColor $t.Muted
    Write-Host ''
    Write-Host '  ────────────────────────────────────' -ForegroundColor $t.Muted
    Write-Host ''

    if (-not (Test-AdminRights)) {
        Write-Host '  Not running as Administrator' -ForegroundColor $t.Warning
        Write-Host '  Repair / Cleanup / Install can elevate when needed' -ForegroundColor $t.Muted
        Write-Host ''
    }

    foreach ($item in $script:MenuItems) {
        Write-Host ("  {0}  {1}" -f $item.Index, $item.Name) -ForegroundColor $t.MenuItem
    }

    Write-Host ''
    Write-Host '  A  About / Help' -ForegroundColor $t.MenuHighlight
    Write-Host '  0  Exit' -ForegroundColor $t.Error
    Write-Host ''
    Write-Host '  Or type a request (e.g. "check battery", "clean temp")' -ForegroundColor $t.Muted
    Write-Host ''
}

Write-ASALog "ASA v$($script:ASAVersion) starting" -Level Info

do {
    Show-MainMenu
    $choice = Read-Host '  Choice'

    if ([string]::IsNullOrWhiteSpace($choice)) { continue }

    if ($choice -eq '0') {
        Write-Host ''
        Write-Host '  Exiting ASA. Goodbye!' -ForegroundColor $script:Theme.Warning
        Write-ASALog 'ASA exited by user' -Level Info
        exit 0
    }

    if ($choice -match '^[Aa]$') {
        Show-About
        continue
    }

    # Numeric menu selection
    if ($choice -match '^\d+$') {
        $selected = $script:MenuItems |
            Where-Object { $_.Index -eq [int]$choice } |
            Select-Object -First 1

        if (-not $selected) {
            Write-Host '  Invalid choice.' -ForegroundColor $script:Theme.Error
            Start-Sleep -Seconds 1
            continue
        }

        try {
            & $selected.Command
        }
        catch {
            Write-Host "  Error in $($selected.Name): $($_.Exception.Message)" -ForegroundColor $script:Theme.Error
            Write-ASALog "Error running $($selected.Command): $_" -Level Error
            Pause
        }
        continue
    }

    # Natural language via IntentEngine
    if (Get-Command Invoke-ASAIntent -ErrorAction SilentlyContinue) {
        try {
            $null = Invoke-ASAIntent -Query $choice
        }
        catch {
            Write-Host "  Intent error: $($_.Exception.Message)" -ForegroundColor $script:Theme.Error
            Write-ASALog "Intent error: $_" -Level Error
            Pause
        }
    }
    else {
        Write-Host '  Type a menu number, or ensure IntentEngine.psm1 is loaded.' -ForegroundColor $script:Theme.Warning
        Start-Sleep -Seconds 1
    }
} while ($true)