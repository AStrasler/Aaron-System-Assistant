<#
.SYNOPSIS
    Windows update status module for ASU
#>

<#
.SYNOPSIS
    Show installed and available Windows update information.

.DESCRIPTION
    Queries the Windows Update agent for available non-hidden updates and displays a concise summary.

.EXAMPLE
    Show-UpdatesMenu
#>
function Get-UpdateSummary {
    param()

    try {
        $Session = New-Object -ComObject Microsoft.Update.Session
        $Searcher = $Session.CreateUpdateSearcher()
        $SearchResult = $Searcher.Search("IsInstalled=0 and IsHidden=0")

        $Updates = @($SearchResult.Updates | ForEach-Object {
            [PSCustomObject]@{
                Title = $_.Title
                KBArticleIDs = ($_.KBArticleIDs -join ', ')
                RebootRequired = [bool]$_.RebootRequired
            }
        })

        return @{ Found = $Updates.Count; Updates = $Updates }
    } catch {
        return @{ Error = $_.Exception.Message; Found = 0; Updates = @() }
    }
}

function Show-UpdatesMenu {
    Clear-Host
    Write-Host "=== Windows Updates ===" -ForegroundColor Cyan

    $Summary = Get-UpdateSummary
    if ($Summary.Error) {
        Write-Host "Unable to query Windows Update: $($Summary.Error)" -ForegroundColor Red
    } else {
        Write-Host "Available updates: $($Summary.Found)" -ForegroundColor White
        if ($Summary.Found -gt 0) {
            $Summary.Updates | Select-Object -First 10 Title, KBArticleIDs, RebootRequired | Format-Table -AutoSize
            if ($Summary.Found -gt 10) {
                Write-Host "Showing first 10 of $($Summary.Found) available updates." -ForegroundColor Yellow
            }
        } else {
            Write-Host "No available non-hidden updates were found." -ForegroundColor Green
        }
    }

    Write-ASULog "Windows update status viewed" -Level "Info"
    Pause
    Show-MainMenu
}

Export-ModuleMember -Function Show-UpdatesMenu,Get-UpdateSummary



