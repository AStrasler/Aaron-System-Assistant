<#
Insert basic comment-based help for exported functions that lack a .SYNOPSIS block.
This is conservative: it only adds a minimal help block immediately above the function
if no comment-based help is detected.
#>
$repoRoot = Split-Path -Path $PSScriptRoot -Parent
$psmFiles = Get-ChildItem -Path $repoRoot -Filter '*.psm1' -File

foreach ($file in $psmFiles) {
    $text = Get-Content -LiteralPath $file.FullName -Raw
    if ($text -match 'Export-ModuleMember\s+-Function\s+(.*)') {
        $m = [regex]::Match($text,'Export-ModuleMember\s+-Function\s+(.*)')
        $names = $m.Groups[1].Value -split ',' | ForEach-Object { $_.Trim() -replace '"','' }
        foreach ($name in $names) {
            $pattern = "function\s+$name\s*\{"
            $fi = [regex]::Match($text,$pattern, 'IgnoreCase')
            if ($fi.Success) {
                # check for .SYNOPSIS within 5 lines before the function
                $startIdx = $fi.Index
                $context = if ($startIdx -gt 200) { $text.Substring($startIdx-200,200) } else { $text.Substring(0,$startIdx) }
                if ($context -notmatch '\.SYNOPSIS') {
                    $help = "<#`r`n.SYNOPSIS`r`n    $name (auto-added help)`r`n#>`r`n"
                    $text = $text.Substring(0,$startIdx) + $help + $text.Substring($startIdx)
                    Write-Output "Added help for $name in $($file.Name)"
                }
            }
        }
        Set-Content -LiteralPath $file.FullName -Value $text -Encoding UTF8
    }
}
Write-Output 'Help insertion complete.'

