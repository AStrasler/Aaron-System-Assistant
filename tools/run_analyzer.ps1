Import-Module PSScriptAnalyzer -Force
$root = Split-Path -Parent $PSScriptRoot
$settings = Join-Path $root 'PSScriptAnalyzer.Settings.psd1'
if (Test-Path $settings) {
	$r = Invoke-ScriptAnalyzer -Path $root -Recurse -Settings $settings
} else {
	$r = Invoke-ScriptAnalyzer -Path $root -Recurse
}
$r | ConvertTo-Json -Depth 6 | Out-File (Join-Path $PSScriptRoot 'analyzer_results.json') -Encoding UTF8
Write-Output 'SAVED'



