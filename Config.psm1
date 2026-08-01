<#
.SYNOPSIS
    Configuration accessor module for ASU
.DESCRIPTION
    Loads `config.json` (if present) and exposes `Get-ASUConfig`, `Get-ASUReportPath`, and `Get-ASULoggingLevel`.
#>

# Load configuration into script scope for this module
$script:ASUConfig = $null
$ConfigPath = Join-Path $PSScriptRoot 'config.json'
if (Test-Path $ConfigPath) {
    try {
        $script:ASUConfig = Get-Content $ConfigPath -Raw | ConvertFrom-Json
    } catch {
        Write-Warning "Failed to parse config.json: $($_.Exception.Message)"
    }
}

<#
.SYNOPSIS
    Returns the parsed ASU configuration object.
.DESCRIPTION
    Returns the configuration parsed from config.json, or $null if none available.
#>
function Get-ASUConfig {
    return $script:ASUConfig
}

<#
.SYNOPSIS
    Compute the report output path.
.PARAMETER RelativeTo
    Base path to resolve the configured report path against. Defaults to the repository root.
.DESCRIPTION
    Returns the configured report path (from config.json) joined with the provided base path, or a default 'Reports' directory.
#>
function Get-ASUReportPath {
    param(
        [string]$RelativeTo = $PSScriptRoot
    )
    $rp = if ($script:ASUConfig -and $script:ASUConfig.ReportPath) { $script:ASUConfig.ReportPath } else { 'Reports' }
    return Join-Path $RelativeTo $rp
}

<#
.SYNOPSIS
    Returns the configured logging level.
.DESCRIPTION
    Returns the LoggingLevel from config.json if present, otherwise 'Info'.
#>
function Get-ASULoggingLevel {
    if ($script:ASUConfig -and $script:ASUConfig.LoggingLevel) { return $script:ASUConfig.LoggingLevel } else { return 'Info' }
}

Export-ModuleMember -Function Get-ASUConfig, Get-ASUReportPath, Get-ASULoggingLevel

