$root = Split-Path -Parent $PSScriptRoot
# PSScriptAnalyzerSuppressMessage -RuleName PSUseDeclaredVarsMoreThanAssignments -Justification 'Variable $fail is used after the loop to determine exit code'
$script:fail = $false
Get-ChildItem -Path $root -Include *.ps1,*.psm1 -Recurse -File | ForEach-Object {
    $path = $_.FullName
    Write-Output "Checking: $path"
    $tokens = $null
    $errors = $null
    [System.Management.Automation.Language.Parser]::ParseFile($path,[ref]$tokens,[ref]$errors) | Out-Null
    if ($errors -and $errors.Count -gt 0) {
        Write-Output "Errors in $path"
        $errors | Format-List
        $script:fail = $true
    } else {
        Write-Output "OK: $path"
    }
}
if ($script:fail) { exit 2 } else { Write-Output 'ALL_PARSE_OK' }



