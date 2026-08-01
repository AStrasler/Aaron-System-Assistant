<# Validate normalized deep test results against a lightweight schema-like check. #>
$normPath = Join-Path $PSScriptRoot 'deep_test_results_normalized.json'
$schemaPath = Join-Path $PSScriptRoot 'deep_test_schema.json'
if (-not (Test-Path $normPath)) { Write-Error "Missing $normPath"; exit 2 }
if (-not (Test-Path $schemaPath)) { Write-Error "Missing $schemaPath"; exit 3 }

$data = Get-Content -Raw $normPath | ConvertFrom-Json
$errors = @()

foreach ($item in $data) {
    if ($item.Type -eq 'Module') {
        if (-not $item.Module) { $errors += "Module entry missing Module field." }
        if ($null -eq $item.Imported) { $errors += "Module $($item.Module): Imported not boolean." }
    } elseif ($item.Type -eq 'Function') {
        if (-not $item.Function) { $errors += "Function entry missing Function name." }
        if ($null -eq $item.Data) { $errors += "Function $($item.Function): Data missing." }
    } else {
        $errors += "Unknown item Type: $($item.Type)";
    }
}

if ($errors.Count -gt 0) {
    Write-Output "Schema validation failed:"; $errors | ForEach-Object { Write-Output " - $_" }
    exit 1
}
Write-Output "Schema validation passed."; exit 0

