# Runs non-interactive smoke tests for all module menu functions
# Overrides interactive helpers (Pause, Read-Host, Show-MainMenu) to keep tests non-blocking

$ErrorActionPreference = 'Continue'
$results = @()

function Pause { return }
function Show-MainMenu { return }
function Read-Host { param($prompt) return 'D' }
function Write-ASULog { param($Message, $Level = 'Info') return }

 $scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Definition
 $repoRoot = Join-Path $scriptRoot '..' | Resolve-Path -ErrorAction SilentlyContinue
 if (-not $repoRoot) { $repoRoot = Join-Path $scriptRoot '..' }
 $modules = Get-ChildItem -Path $repoRoot -Filter *.psm1 -File | ForEach-Object { $_.FullName }

# Ensure Config.psm1 is imported first if present
 $configPath = Join-Path $repoRoot 'Config.psm1'
 if (Test-Path $configPath) { Import-Module -Force $configPath -ErrorAction SilentlyContinue }

# Known menu functions to exercise
$menuFunctions = @(
    'Show-BatteryMenu',
    'Show-CleanupMenu',
    'Show-MemoryMenu',
    'Show-NetworkMenu',
    'Show-StorageMenu',
    'Show-UpdatesMenu',
    'Show-StartupMenu',
    'Show-ReportsMenu',
    'Show-WindowsRepairMenu'
)

foreach ($mod in $modules) {
    try {
        Import-Module -Force $mod -ErrorAction Stop
    } catch {
        $results += [PSCustomObject]@{ Module = $mod; Imported = $false; Error = $_.Exception.Message }
        continue
    }
    $results += [PSCustomObject]@{ Module = $mod; Imported = $true; Error = $null }
}

foreach ($fn in $menuFunctions) {
    $entry = [PSCustomObject]@{ Function = $fn; Ran = $false; Error = $null; Output = $null }
    if (Get-Command $fn -ErrorAction SilentlyContinue) {
        try {
            $out = & $fn 2>&1 | Out-String
            $entry.Ran = $true
            $entry.Output = $out
        } catch {
            $entry.Error = $_.Exception.Message
        }
    } else {
        $entry.Error = 'Function not exported/loaded'
    }
    $results += $entry
}

$results | ConvertTo-Json -Depth 6 | Out-File (Join-Path $scriptRoot 'deep_test_results.json') -Encoding UTF8
Write-Output 'DEEP_TEST_DONE'
