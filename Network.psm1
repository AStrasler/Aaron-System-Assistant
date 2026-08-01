<#
.SYNOPSIS
    Network diagnostics module for ASU
#>

<#
.SYNOPSIS
    Show interactive network diagnostics and basic connectivity tests.

.DESCRIPTION
    Displays local and public IP information, gateway, and runs a configurable ping test.

.EXAMPLE
    Show-NetworkMenu

.NOTES
    Intended for interactive use within ASU.
#>
<#
.SYNOPSIS
    Show-NetworkMenu (auto-added help)
#>
function Show-NetworkMenu {
    Clear-Host
    Write-Host "=== Network Diagnostics ===" -ForegroundColor Cyan

    $IP = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object {$_.InterfaceIndex -ne 1}).IPAddress
    Write-Host "Local IP: $IP" -ForegroundColor White
    Write-Host "Gateway: $(Get-NetIPConfiguration | Select-Object -ExpandProperty IPv4DefaultGateway | Select-Object -ExpandProperty NextHop)" -ForegroundColor White

    try {
        $PublicIP = Invoke-RestMethod -Uri 'https://api.ipify.org' -Method Get -ErrorAction Stop
        Write-Host "Public IP: $PublicIP" -ForegroundColor White
    } catch {
        Write-Host "Public IP: Unavailable" -ForegroundColor Yellow
    }

    # Use configurable ping target to avoid hardcoding
    $cfg = Get-ASUConfig
    $PingTarget = if ($cfg -and $cfg.PingTarget) { $cfg.PingTarget } else { '8.8.8.8' }
    Write-Host "`nRunning ping test to $PingTarget..."
    Test-Connection -ComputerName $PingTarget -Count 4 -ErrorAction SilentlyContinue

    Write-ASULog "Network diagnostics performed" -Level "Info"
    Pause
    Show-MainMenu
}

Export-ModuleMember -Function Show-NetworkMenu



