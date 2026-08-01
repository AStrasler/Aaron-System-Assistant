$root = "c:\Users\aaron_lc3zh3u\Documents\GitHub\Aaron-System-Utility"
Get-ChildItem -Path $root -Filter *.psm1 -File | ForEach-Object {
    $path = $_.FullName
    Write-Output "Importing: $path"
    try {
        Import-Module -Force -ErrorAction Stop $path
        $exports = (Get-Module -ListAvailable | Where-Object { $_.Path -eq $path })
        if ($exports) {
            Write-Output "Module loaded: $($_.Name)"
        }
        # List functions defined in session that match Show-*Menu
        Get-Command -CommandType Function -ErrorAction SilentlyContinue | Where-Object { $_.Name -like 'Show-*Menu' } | ForEach-Object { Write-Output "  Function: $($_.Name) from $($_.ModuleName)" }
    } catch {
        Write-Output "  ERROR importing $path : $($_.Exception.Message)"
    }
}
Write-Output 'IMPORT_TEST_DONE'


