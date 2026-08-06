# IntentEngine.psm1 — Natural Language Parser for ASA

$script:IntentMap = @{
    # ---[ Cleanup ]---
    'clean|cleanup|temp|junk|disk space|free space|remove temp|temporary files' = @{
        Module = 'Show-CleanupMenu'
        Description = 'Clean temporary files and free disk space'
    }

    # ---[ Battery ]---
    'battery|charge|power|remaining|run time|battery health|battery status' = @{
        Module = 'Show-BatteryMenu'
        Description = 'Check battery status and generate report'
    }

    # ---[ Memory ]---
    'memory|ram|usage|process|slow|lag|high memory|memory usage|top processes' = @{
        Module = 'Show-MemoryMenu'
        Description = 'Analyze memory usage and top processes'
    }

    # ---[ Network ]---
    'network|wifi|internet|ip|dns|ping|gateway|connection|speed test' = @{
        Module = 'Show-NetworkMenu'
        Description = 'Network diagnostics and connectivity test'
    }

    # ---[ Storage ]---
    'storage|disk|drive|partition|health|ssd|hdd|free space|disk usage' = @{
        Module = 'Show-StorageMenu'
        Description = 'Storage health and partition details'
    }

    # ---[ Updates ]---
    'update|windows update|patch|install|restart|reboot|pending updates' = @{
        Module = 'Show-UpdatesMenu'
        Description = 'Check and install Windows updates'
    }

    # ---[ Startup ]---
    'startup|boot|login|autostart|disable startup|startup apps' = @{
        Module = 'Show-StartupMenu'
        Description = 'Manage startup applications'
    }

    # ---[ Repair ]---
    'repair|sfc|dism|chkdsk|fix|corrupt|broken|system file|health' = @{
        Module = 'Show-WindowsRepairMenu'
        Description = 'Run system repair tools (SFC, DISM, CHKDSK)'
    }

    # ---[ Reports ]---
    'report|diagnostic|health check|summary|system info' = @{
        Module = 'Show-ReportsMenu'
        Description = 'Generate detailed system report'
    }

    # ---[ Exit / Help ]---
    'exit|quit|bye|goodbye|close' = @{
        Module = 'Exit'
        Description = 'Exit ASA'
    }
    'help|what can you do|options|menu|?|commands' = @{
        Module = 'Help'
        Description = 'Show available commands'
    }
}

function Resolve-ASAIntent {
    param([string]$Query)

    if ([string]::IsNullOrWhiteSpace($Query)) { return $null }

    $lowerQuery = $Query.ToLower()

    foreach ($pattern in $script:IntentMap.Keys) {
        if ($lowerQuery -match $pattern) {
            $result = $script:IntentMap[$pattern]
            return $result
        }
    }

    return $null
}

function Invoke-ASAIntent {
    param([string]$Query)

    $intent = Resolve-ASAIntent -Query $Query

    if (-not $intent) {
        Write-Host "`n  🤖 Sorry, I didn't understand that."
        Write-Host "     Try: 'help' to see what I can do." -ForegroundColor Gray
        return $false
    }

    if ($intent.Module -eq 'Exit') {
        Write-Host "`n  👋 Goodbye!" -ForegroundColor Green
        exit 0
    }

    if ($intent.Module -eq 'Help') {
        Show-ASAHelp
        return $true
    }

    # Check if the module function exists
    if (Get-Command $intent.Module -ErrorAction SilentlyContinue) {
        Write-Host "`n  💡 Running: $($intent.Description)" -ForegroundColor Cyan
        & $intent.Module
        return $true
    } else {
        Write-Host "`n  ⚠️ The module '$($intent.Module)' is not available." -ForegroundColor Yellow
        Write-Host "     Please ensure the module is loaded." -ForegroundColor Gray
        return $false
    }
}

function Show-ASAHelp {
    Clear-Host
    Write-Host "`n  🤖 ASA — Natural Language Commands" -ForegroundColor Cyan
    Write-Host "  ──────────────────────────────────" -ForegroundColor Gray
    Write-Host ""

    Write-Host "  Try saying:" -ForegroundColor Yellow
    $uniqueDescriptions = $script:IntentMap.Values | Select-Object -Property Description -Unique
    foreach ($item in $uniqueDescriptions) {
        if ($item.Description -and $item.Description -ne 'Exit ASA' -and $item.Description -ne 'Show available commands') {
            Write-Host "    • $($item.Description)" -ForegroundColor White
        }
    }

    Write-Host ""
    Write-Host "  📌 You can also type menu numbers." -ForegroundColor Gray
    Write-Host "  💡 Say 'exit' to quit." -ForegroundColor Gray
    Write-Host ""
    Pause
}

Export-ModuleMember -Function Resolve-ASAIntent, Invoke-ASAIntent, Show-ASAHelp