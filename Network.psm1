<#
.SYNOPSIS
    Network diagnostics module for ASU
#>

function Show-NetworkMenu {
    Clear-Host
    Write-Host '=== Network Diagnostics ===' -ForegroundColor Cyan

    $ipAddresses = Get-NetIPAddress -AddressFamily IPv4 -ErrorAction SilentlyContinue |
        Where-Object { $_.InterfaceIndex -ne 1 -and $_.IPAddress -notlike '169.254.*' }
    $IP = ($ipAddresses | Select-Object -First 1).IPAddress
    Write-Host "Local IP: $IP" -ForegroundColor White

    $gatewayObj = Get-NetIPConfiguration -ErrorAction SilentlyContinue |
        Select-Object -ExpandProperty IPv4DefaultGateway -ErrorAction SilentlyContinue |
        Select-Object -First 1
    $gateway = if ($gatewayObj) { $gatewayObj.NextHop } else { 'N/A' }
    Write-Host "Gateway: $gateway" -ForegroundColor White

    try {
        $PublicIP = Invoke-RestMethod -Uri 'https://api.ipify.org' -Method Get -TimeoutSec 5 -ErrorAction Stop
        Write-Host "Public IP: $PublicIP" -ForegroundColor White
    }
    catch {
        Write-Host 'Public IP: Unavailable' -ForegroundColor Yellow
    }

    Write-Host "`nRunning ping test to 8.8.8.8..."
    Test-Connection -ComputerName 8.8.8.8 -Count 4 -ErrorAction SilentlyContinue

    Write-ASULog 'Network diagnostics performed' -Level Info
    Pause
}

Export-ModuleMember -Function Show-NetworkMenu