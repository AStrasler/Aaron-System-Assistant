# LicenseCheck.psm1 — ASA Licensing Module (Keymint + Local Fallback)
# Supports: Free tier Keymint API, local fallback, and pause system

# ---[ Load .env file ]---
function Import-ASAEnvFile {
    param([string]$Path = "$PSScriptRoot\.env")

    if (Test-Path $Path) {
        $lines = Get-Content $Path -ErrorAction SilentlyContinue
        foreach ($line in $lines) {
            if ($line -match '^\s*([^#=]+)=(.*)$') {
                $key = $matches[1].Trim()
                $value = $matches[2].Trim()
                [Environment]::SetEnvironmentVariable($key, $value, 'Process')
            }
        }
        return $true
    }
    return $false
}

# Load .env at startup
Import-ASAEnvFile

# ---[ Configuration ]---
$script:LicensePath = Join-Path $PSScriptRoot "license.key"
$script:PausePath = Join-Path $PSScriptRoot "paused.json"
$script:KeymintBaseUrl = "https://api.keymint.dev/v1"  # Update if different

# Get API key from environment variable (loaded from .env)
$script:KeymintApiKey = $env:KEYMINT_API_KEY

# Fallback to config file if env var is not set
if (-not $script:KeymintApiKey) {
    $configPath = Join-Path $PSScriptRoot "keymint.config.json"
    if (Test-Path $configPath) {
        $config = Get-Content $configPath -Raw | ConvertFrom-Json
        $script:KeymintApiKey = $config.apiKey
    }
}

# ---[ Helper: Get Machine Fingerprint ]---
function Get-ASAFingerprint {
    try {
        $Parts = @(
            (Get-WmiObject Win32_ComputerSystem).Name,
            (Get-WmiObject Win32_BIOS).SerialNumber,
            (Get-WmiObject Win32_Processor).ProcessorId,
            (Get-WmiObject Win32_BaseBoard).SerialNumber
        )
        $String = ($Parts -join "|").ToUpper()
        $Bytes = [System.Text.Encoding]::UTF8.GetBytes($String)
        $Hash = [System.Security.Cryptography.SHA256]::Create().ComputeHash($Bytes)
        return [Convert]::ToBase64String($Hash).Substring(0, 16)
    } catch {
        return "FALLBACK-" + (Get-Date).Ticks.ToString().Substring(0, 16)
    }
}

# ---[ Keymint API Functions ]---
function Invoke-KeymintRequest {
    param(
        [string]$Endpoint,
        [string]$Method = "GET",
        [hashtable]$Body = $null
    )

    if (-not $script:KeymintApiKey) {
        Write-Warning "Keymint API key not configured. Falling back to local licensing."
        return $null
    }

    $Uri = "$script:KeymintBaseUrl/$Endpoint"
    $Headers = @{
        "Authorization" = "Bearer $script:KeymintApiKey"
        "Content-Type"  = "application/json"
    }

    try {
        $Params = @{
            Uri         = $Uri
            Method      = $Method
            Headers     = $Headers
            ErrorAction = "Stop"
        }
        if ($Body) {
            $Params.Body = ($Body | ConvertTo-Json -Depth 3)
        }

        $Response = Invoke-RestMethod @Params
        return $Response
    } catch {
        Write-Warning "Keymint API error: $($_.Exception.Message)"
        return $null
    }
}

function New-ASAKeymintLicense {
    <#
    .SYNOPSIS
    Creates a new free license via Keymint API.
    #>
    $Fingerprint = Get-ASAFingerprint

    $LicenseData = @{
        customer = @{
            name  = "Personal / Open-Source User"
            email = "user-$Fingerprint@localhost"
        }
        product   = "ASA"
        plan      = "free"
        hostId    = $Fingerprint
        metadata  = @{
            version  = $script:ASAVersion
            platform = "Windows"
        }
    }

    $Response = Invoke-KeymintRequest -Endpoint "licenses" -Method "POST" -Body $LicenseData

    if ($Response -and $Response.id) {
        # Save license locally
        $License = @{
            type        = "free"
            licensee    = "Personal / Open-Source User"
            fingerprint = $Fingerprint
            keymintId   = $Response.id
            issued      = (Get-Date).ToString("yyyy-MM-dd")
            expiry      = (Get-Date).AddYears(1).ToString("yyyy-MM-dd")
            key         = $Response.key
        }
        $License | ConvertTo-Json -Depth 3 | Set-Content $script:LicensePath
        Write-Host "✅ Free license created via Keymint" -ForegroundColor Green
        Write-Host "   Valid until: $($License.expiry)" -ForegroundColor Gray
        return $true
    } else {
        Write-Warning "Keymint license creation failed. Falling back to local generation."
        return $false
    }
}

# ---[ Local Fallback License Generation ]---
function New-ASALocalLicense {
    $Fingerprint = Get-ASAFingerprint
    $License = @{
        type        = "free"
        licensee    = "Personal / Open-Source User"
        fingerprint = $Fingerprint
        issued      = (Get-Date).ToString("yyyy-MM-dd")
        expiry      = (Get-Date).AddYears(1).ToString("yyyy-MM-dd")
        key         = "LOCAL-" + [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($Fingerprint)).Substring(0, 12)
    }
    $License | ConvertTo-Json -Depth 3 | Set-Content $script:LicensePath
    Write-Host "✅ Free license generated locally (offline mode)" -ForegroundColor Yellow
    Write-Host "   Valid until: $($License.expiry)" -ForegroundColor Gray
    return $true
}

# ---[ Main License Check ]---
function Test-ASALicense {
    <#
    .SYNOPSIS
    Validates license. Uses Keymint if available, falls back to local.
    Handles pause state and graceful exit.
    #>

    # Check if system is paused
    if (Test-Path $script:PausePath) {
        Show-ASAPauseScreen
        return $false
    }

    # Check if license exists
    if (-not (Test-Path $script:LicensePath)) {
        Write-Host "🔑 No license found. Attempting to generate..." -ForegroundColor Yellow

        # Try Keymint first
        $success = New-ASAKeymintLicense
        if (-not $success) {
            # Fallback to local
            $success = New-ASALocalLicense
        }

        if ($success) {
            return $true
        } else {
            Write-Host "❌ Could not generate license. Please check network or API key." -ForegroundColor Red
            return $false
        }
    }

    # Load existing license
    try {
        $License = Get-Content $script:LicensePath -Raw | ConvertFrom-Json

        # Check expiry
        if ($License.expiry -lt (Get-Date)) {
            Write-Host "⚠️ License expired. Re-generating..." -ForegroundColor Yellow
            Remove-Item $script:LicensePath -Force
            # Try Keymint first
            if (-not (New-ASAKeymintLicense)) {
                New-ASALocalLicense
            }
            return $true
        }

        # Validate fingerprint
        $CurrentFingerprint = Get-ASAFingerprint
        if ($License.fingerprint -ne $CurrentFingerprint) {
            Write-Host "⚠️ Hardware change detected. Re-generating license..." -ForegroundColor Yellow
            Remove-Item $script:LicensePath -Force
            if (-not (New-ASAKeymintLicense)) {
                New-ASALocalLicense
            }
            return $true
        }

        # Optional: Verify with Keymint (if online)
        if ($script:KeymintApiKey -and $License.keymintId) {
            $Remote = Invoke-KeymintRequest -Endpoint "licenses/$($License.keymintId)"
            if ($Remote -and $Remote.status -eq "revoked") {
                Write-Host "❌ License has been revoked remotely. Pausing ASA." -ForegroundColor Red
                Invoke-ASAPause -Reason "License revoked by Keymint"
                return $false
            }
        }

        Write-Host "✅ License valid ($($License.type)) until $($License.expiry)" -ForegroundColor Green
        return $true

    } catch {
        Write-Host "❌ Corrupt license file. Regenerating." -ForegroundColor Red
        Remove-Item $script:LicensePath -Force -ErrorAction SilentlyContinue
        if (-not (New-ASAKeymintLicense)) {
            New-ASALocalLicense
        }
        return $true
    }
}

# ---[ Pause System ]---
function Invoke-ASAPause {
    param([string]$Reason = "License violation detected")

    $PauseMarker = @{
        Paused    = $true
        PausedAt  = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
        Reason    = $Reason
        Reversible = $true
        Contact   = "asa-licensing@yourdomain.com"
    }
    $PauseMarker | ConvertTo-Json -Depth 3 | Set-Content $script:PausePath

    Show-ASAPauseScreen
}

function Show-ASAPauseScreen {
    Clear-Host
    Write-Host @"
╔══════════════════════════════════════════════════════════════╗
║  🔒  ASA PAUSED — LICENSE ISSUE DETECTED                    ║
╠══════════════════════════════════════════════════════════════╣
║                                                              ║
║  ASA has been paused due to a license issue.                ║
║                                                              ║
║  ⚠️  YOUR SYSTEM IS UNCHANGED                               ║
║                                                              ║
║  No files have been modified.                               ║
║  No registry keys were changed.                             ║
║  Your data is safe.                                         ║
║                                                              ║
║  To restore access:                                         ║
║  1. Contact: asa-licensing@yourdomain.com                   ║
║  2. Subject: "ASA License Issue"                            ║
║  3. Include your license key (if you have one)              ║
║                                                              ║
║  Once resolved, you'll receive a confirmation file          ║
║  that instantly restores full access.                       ║
║                                                              ║
║  No restart required. No data loss.                         ║
║  Everything returns to normal immediately.                  ║
║                                                              ║
║  📁 For help: asa-licensing@yourdomain.com                  ║
║                                                              ║
║  ASA will exit now.                                         ║
╚══════════════════════════════════════════════════════════════╝
"@ -ForegroundColor Yellow -BackgroundColor Black

    Write-ASALog "ASA paused: $Reason" -Level Warning
    exit 0
}

function Resume-ASA {
    if (Test-Path $script:PausePath) {
        Remove-Item $script:PausePath -Force
        Write-Host "✅ ASA has been restored." -ForegroundColor Green
        Write-Host "   All features are now available." -ForegroundColor Gray
    } else {
        Write-Host "✅ ASA is already active." -ForegroundColor Green
    }
}

# ---[ Admin Override ]---
function Invoke-ASAForceResume {
    param([string]$AdminKey)

    $ValidAdminKey = "Bore#621Rise!"  # CHANGE THIS!

    if ($AdminKey -eq $ValidAdminKey) {
        Remove-Item $script:PausePath -Force -ErrorAction SilentlyContinue
        Write-Host "✅ Admin override: ASA resumed." -ForegroundColor Green
        Write-ASALog "Admin override: ASA resumed" -Level Info
    } else {
        Write-Host "❌ Invalid admin key." -ForegroundColor Red
    }
}

# ---[ Export ]---
Export-ModuleMember -Function Test-ASALicense, Invoke-ASAPause, Resume-ASA, Invoke-ASAForceResume