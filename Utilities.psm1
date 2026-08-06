# Utilities.psm1 — Core helper functions for ASA

function Set-ASAConsoleTheme {
    <#
    .SYNOPSIS
    Detects Windows theme (Dark/Light) and returns a color object.
    .NOTES
    All colors are valid System.ConsoleColor values.
    #>
    try {
        $LightMode = (Get-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "SystemUsesLightTheme" -ErrorAction SilentlyContinue).SystemUsesLightTheme

        if ($LightMode -eq 1) {
            # Light theme — uses dark text on light background
            $Theme = @{
                Name          = "Light"
                Title         = "DarkBlue"
                Muted         = "Gray"
                Normal        = "DarkGray"
                MenuItem      = "DarkCyan"
                MenuHighlight = "DarkGreen"
                Warning       = "DarkYellow"
                Error         = "DarkRed"
                Success       = "DarkGreen"
                Background    = "White"
            }
        } else {
            # Dark theme — uses light text on dark background (default)
            $Theme = @{
                Name          = "Dark"
                Title         = "Cyan"
                Muted         = "Gray"
                Normal        = "White"
                MenuItem      = "Cyan"
                MenuHighlight = "Yellow"
                Warning       = "Yellow"
                Error         = "Red"
                Success       = "Green"
                Background    = "Black"
            }
        }
    } catch {
        # Fallback to safe dark theme if registry access fails
        $Theme = @{
            Name          = "Dark (Fallback)"
            Title         = "Cyan"
            Muted         = "Gray"
            Normal        = "White"
            MenuItem      = "Cyan"
            MenuHighlight = "Yellow"
            Warning       = "Yellow"
            Error         = "Red"
            Success       = "Green"
            Background    = "Black"
        }
    }

    # Return as a custom object so properties work with -ForegroundColor
    return [pscustomobject]$Theme
}

function Test-AdminRights {
    <#
    .SYNOPSIS
    Checks if the current PowerShell session has administrator privileges.
    #>
    $Identity = [System.Security.Principal.WindowsIdentity]::GetCurrent()
    $Principal = New-Object System.Security.Principal.WindowsPrincipal($Identity)
    return $Principal.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)
}

# Export the functions so they're available in ASA.ps1
Export-ModuleMember -Function Set-ASAConsoleTheme, Test-AdminRights