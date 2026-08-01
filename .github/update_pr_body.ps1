$token = $env:GITHUB_TOKEN
if (-not $token) { $token = $env:GH_TOKEN }
if (-not $token) { Write-Error 'No GitHub token found in GITHUB_TOKEN or GH_TOKEN'; exit 2 }
$body = Get-Content -LiteralPath '.\.github\PR_UPDATE.md' -Raw
$payload = @{ body = $body } | ConvertTo-Json -Depth 5
Invoke-RestMethod -Uri 'https://api.github.com/repos/AStrasler/Aaron-System-Utility/pulls/2' -Method Patch -Headers @{ Authorization = "token $token"; 'User-Agent' = 'asu-agent' } -ContentType 'application/json' -Body $payload
Write-Output 'PR update successful'

