<#
.SYNOPSIS
    Helper to register a daily scheduled task that runs ASU_maintenance.ps1
.DESCRIPTION
    Creates or updates a Windows Scheduled Task under the current user to run
    the maintenance script daily at a configured time.
#>
param(
    [string]$TaskName = 'ASU_Maintenance_Daily',
    [string]$Time = '03:00'
)

$ScriptPath = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition
$MaintenanceScript = Join-Path $ScriptPath 'ASU_maintenance.ps1'

if (-not (Test-Path $MaintenanceScript)) {
    Write-Error "Maintenance script not found: $MaintenanceScript"
    exit 1
}

$action = "powershell -NoProfile -ExecutionPolicy Bypass -File `"$MaintenanceScript`""

Write-Output "Registering scheduled task '$TaskName' to run daily at $Time"

# Use schtasks for broad compatibility without requiring explicit Task Scheduler modules
$arguments = @('/Create', '/TN', $TaskName, '/TR', $action, '/SC', 'DAILY', '/ST', $Time, '/RL', 'HIGHEST', '/F')

try {
    & schtasks.exe @arguments
    Write-Output "Scheduled task created/updated. Check Task Scheduler for details." 
} catch {
    Write-Error "Failed to create scheduled task: $($_.Exception.Message)"
    exit 1
}
