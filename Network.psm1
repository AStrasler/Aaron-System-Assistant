<#
.SYNOPSIS
    Network diagnostics module for ASA
#>

function Show-NetworkMenu {
    Clear-Host
    Write-Host "`n  🌐 Network Diagnostics" -ForegroundColor Cyan
    Write-Host "  ──────────────────────" -ForegroundColor Gray

    # ---[ Local IP ]---
    $ipAddresses = Get-NetIPAddress -AddressFamily IPv4 -ErrorAction SilentlyContinue |
        Where-Object { $_.InterfaceIndex -ne 1 -and $_.IPAddress -notlike '169.254.*' -and $_.IPAddress -notlike '127.*' }
    $IP = ($ipAddresses | Select-Object -First 1).IPAddress
    Write-Host "`n  📡 Local IP   : $IP" -ForegroundColor White

    # ---[ Gateway ]---
    $gatewayObj = Get-NetIPConfiguration -ErrorAction SilentlyContinue |
        Select-Object -ExpandProperty IPv4DefaultGateway -ErrorAction SilentlyContinue |
        Select-Object -First 1
    $gateway = if ($gatewayObj) { $gatewayObj.NextHop } else { 'N/A' }
    Write-Host "  🚪 Gateway    : $gateway" -ForegroundColor White

    # ---[ DNS Servers ]---
    $dnsServers = Get-DnsClientServerAddress -AddressFamily IPv4 -ErrorAction SilentlyContinue |
        Where-Object { $_.ServerAddresses -and $_.InterfaceIndex -ne 1 } |
        Select-Object -ExpandProperty ServerAddresses -First 3
    $dnsList = if ($dnsServers) { $dnsServers -join ', ' } else { 'N/A' }
    Write-Host "  📋 DNS Servers: $dnsList" -ForegroundColor White

    # ---[ Public IP ]---
    try {
        $PublicIP = Invoke-RestMethod -Uri 'https://api.ipify.org' -Method Get -TimeoutSec 5 -ErrorAction Stop
        Write-Host "  🌍 Public IP  : $PublicIP" -ForegroundColor Green
    }
    catch {
        Write-Host "  🌍 Public IP  : Unavailable (check internet)" -ForegroundColor Yellow
    }

    # ---[ Ping Test ]---
    Write-Host "`n  📶 Running ping test to 8.8.8.8..." -ForegroundColor Gray
    $pingResults = Test-Connection -ComputerName 8.8.8.8 -Count 4 -ErrorAction SilentlyContinue

    if ($pingResults) {
        $successCount = ($pingResults | Where-Object { $_.StatusCode -eq 0 }).Count
        $avgLatency = [math]::Round(($pingResults | Measure-Object -Property ResponseTime -Average).Average, 1)
        Write-Host "  ✅ Ping successful: $successCount/4 replies" -ForegroundColor Green
        Write-Host "  ⏱️ Average latency: $avgLatency ms" -ForegroundColor White
    } else {
        Write-Host "  ❌ Ping failed. Check network connection." -ForegroundColor Red
    }

    Write-ASALog "Network diagnostics performed" -Level Info
    Pause
}

Export-ModuleMember -Function Show-NetworkMenu