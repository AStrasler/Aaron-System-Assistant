# fix-smart-quotes.ps1 — Replaces typographic "smart quotes" with straight
# ASCII quotes across all .ps1/.psm1 files. Run from the repo root.
#
# Usage:  powershell -NoProfile -File .\fix-smart-quotes.ps1

$files = Get-ChildItem -Path . -Include *.ps1, *.psm1 -Recurse -File
$changedCount = 0

foreach ($file in $files) {
    $content = Get-Content -Path $file.FullName -Raw -Encoding UTF8
    $original = $content

    # Curly double quotes -> straight double quote
    $content = $content -replace [char]0x201C, '"'
    $content = $content -replace [char]0x201D, '"'
    # Curly single quotes / apostrophes -> straight single quote
    $content = $content -replace [char]0x2018, "'"
    $content = $content -replace [char]0x2019, "'"

    if ($content -ne $original) {
        Set-Content -Path $file.FullName -Value $content -NoNewline -Encoding UTF8
        Write-Host "Fixed: $($file.FullName)" -ForegroundColor Yellow
        $changedCount++
    }
}

Write-Host ""
Write-Host "Done. $changedCount file(s) had smart quotes replaced." -ForegroundColor Green