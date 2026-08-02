<#
.SYNOPSIS
    Non-interactive maintenance runner for Aaron System Utility
.DESCRIPTION
    Performs a safe set of maintenance tasks (cleanup temp, generate HTML report).
    Designed to be used manually or by a scheduler. Does not require elevation.
#>
param(
    [switch]$DryRun,
    [switch]$LogToFile
)

$ScriptPath = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition

# Import config helpers (Get-ASUReportPath, Get-ASULoggingLevel)
Import-Module "$ScriptPath\Config.psm1" -Force
# Import modules with non-interactive functions
Import-Module "$ScriptPath\Cleanup.psm1" -Force
Import-Module "$ScriptPath\Battery.psm1" -Force
Import-Module "$ScriptPath\Memory.psm1" -Force
Import-Module "$ScriptPath\Network.psm1" -Force
Import-Module "$ScriptPath\Storage.psm1" -Force
Import-Module "$ScriptPath\Updates.psm1" -Force
Import-Module "$ScriptPath\Startup.psm1" -Force
Import-Module "$ScriptPath\Utilities.psm1" -Force
Import-Module "$ScriptPath\WindowsRepair.psm1" -Force
Import-Module "$ScriptPath\Reports.psm1" -Force

function Write-ShortLog {
    param($Message, $Level = 'Info')
    $ts = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    $line = "[$ts] [$Level] $Message"
    Write-Output $line
    if ($LogToFile) {
        $rp = Get-ASUReportPath -RelativeTo $ScriptPath
        if (-not (Test-Path $rp)) { New-Item -Path $rp -ItemType Directory -Force | Out-Null }
        $logFile = Join-Path $rp 'ASU_Maintenance.log'
        Add-Content -Path $logFile -Value $line
    }
}

Write-ShortLog "Starting ASU maintenance (DryRun=$DryRun)" 'Info'

# Run non-interactive module tasks and collect results

$results = @{}

Write-ShortLog "Invoking Cleanup.Invoke-Cleanup (DryRun=$DryRun)" 'Info'
$cleanup = if ($DryRun) { Invoke-Cleanup -DryRun } else { Invoke-Cleanup }
$results['Cleanup'] = $cleanup

Write-ShortLog "Invoking Battery.Invoke-BatteryReport" 'Info'
try { $results['Battery'] = Invoke-BatteryReport -OutputPath (Join-Path $env:TEMP 'battery-report.html') } catch { $results['Battery'] = @{ Error = $_.Exception.Message } }

Write-ShortLog "Collecting memory summary" 'Info'
try { $results['Memory'] = Get-MemorySummary } catch { $results['Memory'] = @{ Error = $_.Exception.Message } }

Write-ShortLog "Collecting network diagnostics" 'Info'
try { $results['Network'] = Get-NetworkDiagnostics } catch { $results['Network'] = @{ Error = $_.Exception.Message } }

Write-ShortLog "Collecting storage summary" 'Info'
try { $results['Storage'] = Get-StorageSummary } catch { $results['Storage'] = @{ Error = $_.Exception.Message } }

Write-ShortLog "Collecting update summary" 'Info'
try { $results['Updates'] = Get-UpdateSummary } catch { $results['Updates'] = @{ Error = $_.Exception.Message } }

Write-ShortLog "Collecting startup items" 'Info'
try { $results['Startup'] = Get-StartupItems } catch { $results['Startup'] = @{ Error = $_.Exception.Message } }

Write-ShortLog "Collecting utilities list" 'Info'
try { $results['Utilities'] = Get-UtilitiesList } catch { $results['Utilities'] = @{ Error = $_.Exception.Message } }

Write-ShortLog "Collecting windows diagnostics" 'Info'
try { $results['Windows'] = Get-WindowsDiagnostics } catch { $results['Windows'] = @{ Error = $_.Exception.Message } }

# Generate combined HTML report with collected results
try {
    $rp = Get-ASUReportPath -RelativeTo $ScriptPath
    if (-not (Test-Path $rp)) { New-Item -Path $rp -ItemType Directory -Force | Out-Null }
    $ReportFile = Join-Path $rp "ASU_Report_$(Get-Date -Format 'yyyyMMdd_HHmmss').html"

    $body = "<html><head><title>ASU System Report</title></head><body><h1>Aaron System Utility Report</h1><p>Generated: $(Get-Date)</p>"
    $body += "<h2>System Info</h2><pre>$(Get-ComputerInfo | Out-String)</pre>"
    $body += "<h2>Module Results (JSON)</h2><pre>$(($results | ConvertTo-Json -Depth 5) | Out-String)</pre>"
    $body += "</body></html>"

    $body | Out-File $ReportFile -Encoding UTF8
    Write-ShortLog "HTML Report generated: $ReportFile" 'Info'
} catch {
    Write-ShortLog "Report generation failed: $($_.Exception.Message)" 'Error'
}

Write-ShortLog "ASU maintenance completed" 'Info'

if ($DryRun) { Write-ShortLog "Note: Dry-run mode - no changes were made" 'Info' }
