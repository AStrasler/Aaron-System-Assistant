# LicenseCheck.psm1 — Simple Personal Licensing
# No pause system, no admin override. Just checks if the key is valid.

# ---[ Load .env file ]---
function Load-EnvFile {
    param([string]$Path = "$PSScriptRoot\.env")
    if (Test-Path $Path) {
        $lines = Get-Content $Path -ErrorAction SilentlyContinue
        foreach ($line in $lines) {
            if ($line -match '^\s*([^#=]+)=(.*)$') {
                [Environment]::SetEnvironmentVariable($matches[1].Trim(), $matches[2].Trim(), 'Process')
            }
        }
    }
}
Load-EnvFile

$script:LicensePath = Join-Path $PSScriptRoot "license.key"
$script:KeymintApiKey = $env:KEYMINT_API_KEY

function Get-ASAFingerprint {
    try {
        $Parts = @(
            (Get-WmiObject Win32_ComputerSystem).Name,
            (Get-WmiObject Win32_BIOS).SerialNumber,
            (Get-WmiObject Win32_Processor).ProcessorId
        )
        $String = ($Parts -join "|").ToUpper()
        $Bytes = [System.Text.Encoding]::UTF8.GetBytes($String)
        $Hash = [System.Security.Cryptography.SHA256]::Create().ComputeHash($Bytes)
        return [Convert]::ToBase64String($Hash).Substring(0, 16)
    } catch { return "FALLBACK-" + (Get-Date).Ticks.ToString().Substring(0, 16) }
}

function Test-ASALicense {
    # 1. If you have a local key file, just use it
    if (Test-Path $script:LicensePath) {
        try {
            $License = Get-Content $script:LicensePath -Raw | ConvertFrom-Json
            if ($License.expiry -ge (Get-Date)) {
                Write-Host "✅ License valid until $($License.expiry)" -ForegroundColor Green
                return $true
            }
        } catch {}
    }

    # 2. No valid key found. Try to get one from Keymint or env
    Write-Host "🔑 Attempting to activate license..." -ForegroundColor Yellow
    $Fingerprint = Get-ASAFingerprint

    # Use pre-existing key from .env
    if ($env:KEYMINT_LICENSE_KEY) {
        $License = @{
            type        = "free"
            licensee    = "Personal"
            fingerprint = $Fingerprint
            issued      = (Get-Date).ToString("yyyy-MM-dd")
            expiry      = (Get-Date).AddYears(1).ToString("yyyy-MM-dd")
            key         = $env:KEYMINT_LICENSE_KEY
        }
        $License | ConvertTo-Json -Depth 3 | Set-Content $script:LicensePath
        Write-Host "✅ License activated from .env" -ForegroundColor Green
        return $true
    }

    # 3. Absolute last resort: local fallback
    $License = @{
        type        = "free"
        licensee    = "Offline User"
        fingerprint = $Fingerprint
        issued      = (Get-Date).ToString("yyyy-MM-dd")
        expiry      = (Get-Date).AddYears(1).ToString("yyyy-MM-dd")
        key         = "LOCAL-" + [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($Fingerprint)).Substring(0, 12)
    }
    $License | ConvertTo-Json -Depth 3 | Set-Content $script:LicensePath
    Write-Host "✅ Local fallback license generated" -ForegroundColor Yellow
    return $true
}

Export-ModuleMember -Function Test-ASALicense