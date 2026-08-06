# --- LOAD ALL SCRIPT MODULES ---
# We do this to ensure every function is loaded into memory BEFORE the menu starts.
# It looks for both .psm1 AND .ps1 files (excluding the main launcher).
$filesToLoad = Get-ChildItem -Path $script:ScriptPath -Include '*.psm1', '*.ps1' -File | Where-Object { $_.Name -ne 'ASA.ps1' }

foreach ($file in $filesToLoad) {
    try {
        # Dot-source the file so functions are actually defined
        . $file.FullName
        Write-ASALog "Loaded script: $($file.BaseName)" -Level Debug
    } catch {
        Write-ASALog "Failed to load $($file.Name): $_" -Level Error
    }
}