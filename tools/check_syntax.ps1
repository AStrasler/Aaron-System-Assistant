$repo = Split-Path -Parent $MyInvocation.MyCommand.Definition
Set-Location $repo
$errors = @()
Get-ChildItem -Path $repo -Include *.ps1,*.psm1 -Recurse | ForEach-Object {
    $f = $_.FullName
    Write-Output "Checking: $f"
    try {
        [System.Management.Automation.Language.Parser]::ParseFile($f,[ref]$null,[ref]$null) | Out-Null
        Write-Output "OK: $($_.Name)"
    } catch {
        $msg = $_.Exception.Message
        Write-Output "ERROR: $($_.Name) - $msg"
        $errors += @{ File = $f; Message = $msg }
    }
}
if ($errors.Count -gt 0) {
    Write-Output "\nSyntax check completed with errors: $($errors.Count) file(s)."
    exit 1
} else {
    Write-Output "\nSyntax check passed: no parse errors."
    exit 0
}
