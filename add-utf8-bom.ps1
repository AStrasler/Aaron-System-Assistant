# add-utf8-bom.ps1 — Re-saves every .ps1/.psm1 with a UTF-8 BOM.
#
# Windows PowerShell 5.1 misreads UTF-8 files that lack a BOM using the
# system's default ANSI codepage instead of UTF-8. Since these scripts
# contain emoji and box-drawing characters, that misread can corrupt
# bytes into characters PowerShell's parser can't handle (e.g. curly
# quotes), causing parse errors that have nothing to do with the code
# itself. Adding a BOM makes the encoding unambiguous.
#
# Usage:  powershell -NoProfile -File .\add-utf8-bom.ps1

$files = Get-ChildItem -Path . -Include *.ps1, *.psm1 -Recurse -File
$changedCount = 0
$utf8Bom = New-Object System.Text.UTF8Encoding $true   # $true = emit BOM

foreach ($file in $files) {
    $bytes = [System.IO.File]::ReadAllBytes($file.FullName)
    $hasBom = $bytes.Length -ge 3 -and $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF

    if (-not $hasBom) {
        # Read as UTF-8 (no BOM) explicitly, then rewrite with BOM
        $text = [System.IO.File]::ReadAllText($file.FullName, [System.Text.Encoding]::UTF8)
        [System.IO.File]::WriteAllText($file.FullName, $text, $utf8Bom)
        Write-Host "Added BOM: $($file.FullName)" -ForegroundColor Yellow
        $changedCount++
    }
}

Write-Host ""
Write-Host "Done. $changedCount file(s) updated with a UTF-8 BOM." -ForegroundColor Green