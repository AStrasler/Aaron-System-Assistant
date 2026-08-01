Get-ChildItem -Path (Split-Path -Parent $PSScriptRoot) -Include *.ps1,*.psm1 -Recurse -File | ForEach-Object {
    $content = Get-Content $_.FullName -Raw -ErrorAction Stop
    $lines = $content -split "\r?\n"
    $new = $lines | ForEach-Object { $_.TrimEnd() }
    $new -join "`r`n" | Set-Content -Path $_.FullName -Encoding UTF8
}
Write-Output 'TRIMMED'


