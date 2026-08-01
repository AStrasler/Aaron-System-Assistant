<# 
.SYNOPSIS
    Network diagnostics module for ASU
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
    
    Write-Host "`nRunning ping test to 8.8.8.8..." 
    Test-Connection -ComputerName 8.8.8.8 -Count 4 -ErrorAction SilentlyContinue
    
    Write-ASULog "Network diagnostics performed" -Level "Info"
    Pause
    Show-MainMenu
}

Export-ModuleMember -Function Show-NetworkMenu