<#
.SYNOPSIS
    Startup management module for ASU
    List startup items and optionally disable selected Run-key entries.
#>

function Get-ASUStartupEntries {
    $entries = New-Object System.Collections.Generic.List[object]

    Get-CimInstance -ClassName Win32_StartupCommand -ErrorAction SilentlyContinue | ForEach-Object {
        $entries.Add([pscustomobject]@{
            Name     = $_.Name
            Command  = $_.Command
            Location = $_.Location
            Source   = 'WMI'
        })
    }

    $hkcuRun = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Run'
    if (Test-Path $hkcuRun) {
        $props = Get-ItemProperty -Path $hkcuRun -ErrorAction SilentlyContinue
        if ($props) {
            $props.PSObject.Properties | Where-Object { $_.Name -notlike 'PS*' } | ForEach-Object {
                $entries.Add([pscustomobject]@{
                    Name     = $_.Name
                    Command  = [string]$_.Value
                    Location = $hkcuRun
                    Source   = 'HKCU-Run'
                })
            }
        }
    }

    $hklmRun = 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Run'
    if (Test-Path $hklmRun) {
        $props = Get-ItemProperty -Path $hklmRun -ErrorAction SilentlyContinue
        if ($props) {
            $props.PSObject.Properties | Where-Object { $_.Name -notlike 'PS*' } | ForEach-Object {
                $entries.Add([pscustomobject]@{
                    Name     = $_.Name
                    Command  = [string]$_.Value
                    Location = $hklmRun
                    Source   = 'HKLM-Run'
                })
            }
        }
    }

    return @($entries | Sort-Object Name)
}

function Disable-ASUStartupEntry {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Name,
        [Parameter(Mandatory = $true)]
        [string]$Location
    )

    if ($Location -like 'HKCU:*') {
        Remove-ItemProperty -Path $Location -Name $Name -ErrorAction Stop
        return
    }

    if ($Location -like 'HKLM:*') {
        if (-not (Test-AdminRights)) {
            throw 'Administrator rights required to change HKLM startup entries.'
        }
        Remove-ItemProperty -Path $Location -Name $Name -ErrorAction Stop
        return
    }

    throw 'This entry cannot be disabled here. Use Task Manager or Task Scheduler.'
}

function Show-StartupList {
    Clear-Host
    Write-Host '=== Startup Items ===' -ForegroundColor Cyan
    Write-Host ''

    $list = Get-ASUStartupEntries
    if ($list.Count -eq 0) {
        Write-Host 'No startup items found.' -ForegroundColor Yellow
    }
    else {
        $list | Format-Table Name, Source, Location, Command -AutoSize -Wrap
        Write-Host ('Total: {0}' -f $list.Count) -ForegroundColor Gray
    }

    Write-Host ''
    Write-Host 'Tip: Task Manager > Startup also shows impact ratings.' -ForegroundColor DarkGray
    Write-ASULog 'Startup items viewed' -Level Info
    Pause
}

function Show-StartupOptimize {
    Clear-Host
    Write-Host '=== Optimize Startup ===' -ForegroundColor Cyan
    Write-Host ''
    Write-Host 'Disabling non-essential startup apps can make login faster.' -ForegroundColor Yellow
    Write-Host 'Do NOT disable security tools, backup agents, or apps you need at login.' -ForegroundColor Yellow
    Write-Host ''
    Write-Host 'Only registry Run-key items can be disabled here.' -ForegroundColor Gray
    Write-Host ''

    $all = Get-ASUStartupEntries
    $editable = @($all | Where-Object { $_.Source -eq 'HKCU-Run' -or $_.Source -eq 'HKLM-Run' })

    if ($editable.Count -eq 0) {
        Write-Host 'No editable Run-key startup items found.' -ForegroundColor Yellow
        Pause
        return
    }

    $i = 0
    foreach ($entry in $editable) {
        $i++
        $line1 = '{0,3}. [{1}] {2}' -f $i, $entry.Source, $entry.Name
        Write-Host $line1 -ForegroundColor White
        Write-Host ('     {0}' -f $entry.Command) -ForegroundColor DarkGray
    }

    Write-Host ''
    Write-Host 'Enter numbers to disable (comma-separated), or 0 to cancel.' -ForegroundColor Yellow
    $raw = Read-Host 'Selection'

    if ([string]::IsNullOrWhiteSpace($raw) -or $raw.Trim() -eq '0') {
        Write-Host 'Cancelled.' -ForegroundColor Yellow
        Pause
        return
    }

    $parts = $raw -split '[, ]+'
    $selected = New-Object System.Collections.Generic.List[object]

    foreach ($part in $parts) {
        if ($part -match '^\d+$') {
            $num = [int]$part
            if ($num -ge 1 -and $num -le $editable.Count) {
                $selected.Add($editable[$num - 1])
            }
        }
    }

    if ($selected.Count -eq 0) {
        Write-Host 'No valid items selected.' -ForegroundColor Red
        Pause
        return
    }

    Write-Host ''
    Write-Host 'Will disable:' -ForegroundColor Yellow
    foreach ($s in $selected) {
        Write-Host (' - {0} ({1})' -f $s.Name, $s.Source) -ForegroundColor Gray
    }
    Write-Host ''

    $confirm = Read-Host 'Type YES to disable these startup items'
    if ($confirm -ne 'YES') {
        Write-Host 'Cancelled.' -ForegroundColor Yellow
        Pause
        return
    }

    $disabled = 0
    foreach ($item in $selected) {
        try {
            if ($item.Source -eq 'HKLM-Run' -and -not (Test-AdminRights)) {
                $elev = Request-Elevation
                if (-not $elev) { continue }
                if (-not (Test-AdminRights)) {
                    Write-Host ('Skipped (need admin): {0}' -f $item.Name) -ForegroundColor Yellow
                    continue
                }
            }

            Disable-ASUStartupEntry -Name $item.Name -Location $item.Location
            Write-Host ('Disabled: {0}' -f $item.Name) -ForegroundColor Green
            Write-ASULog ('Disabled startup item: {0} [{1}]' -f $item.Name, $item.Location) -Level Info
            $disabled++
        }
        catch {
            Write-Host ('Failed: {0} - {1}' -f $item.Name, $_.Exception.Message) -ForegroundColor Red
            Write-ASULog ('Failed disabling startup item {0}: {1}' -f $item.Name, $_) -Level Error
        }
    }

    Write-Host ''
    Write-Host ('Done. Disabled {0} item(s).' -f $disabled) -ForegroundColor Green
    Write-Host 'Sign out or restart to apply at next login.' -ForegroundColor Gray
    Pause
}

function Show-StartupMenu {
    Clear-Host
    Write-Host '=== Startup Applications ===' -ForegroundColor Cyan
    Write-Host '1. List startup items' -ForegroundColor White
    Write-Host '2. Optimize startup (disable selected items)' -ForegroundColor White
    Write-Host '0. Back' -ForegroundColor Yellow
    Write-Host ''

    $choice = Read-Host 'Enter choice'
    switch ($choice) {
        '1' { Show-StartupList }
        '2' { Show-StartupOptimize }
        '0' { return }
        default {
            Write-Host 'Invalid choice.' -ForegroundColor Red
            Pause
        }
    }
}

Export-ModuleMember -Function Show-StartupMenu