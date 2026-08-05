$root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Definition)
Get-ChildItem -Path $root -Filter *.psm1 -File | ForEach-Object {
    $path = $_.FullName
    Write-Output "Importing: $path"
    try {
        Import-Module -Force -ErrorAction Stop $path
        Write-Output "Module loaded: $($_.Name)"
        Get-Command -CommandType Function -ErrorAction SilentlyContinue |
            Where-Object { $_.Name -like 'Show-*Menu' -and $_.Source -eq $_.ModuleName } |
            ForEach-Object { Write-Output "  Function: $($_.Name)" }
    }
    catch {
        Write-Output "  ERROR importing $path : $($_.Exception.Message)"
    }
}
Write-Output 'IMPORT_TEST_DONE'