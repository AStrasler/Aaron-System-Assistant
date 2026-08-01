$path = "c:\Users\aaron_lc3zh3u\Documents\GitHub\Aaron-System-Utility\ASU.ps1"
$tokens = $null
$errors = $null
[System.Management.Automation.Language.Parser]::ParseFile($path,[ref]$tokens,[ref]$errors) | Out-Null
if ($errors -and $errors.Count -gt 0) {
    $errors | Format-List
    exit 2
} else {
    Write-Output 'PARSE_OK'
}


