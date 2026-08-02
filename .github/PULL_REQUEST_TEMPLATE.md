# Pull Request Summary

## *Summary*

This PR aligns module files with exported functions, refactors configuration into a small accessor module (`Config.psm1`), and improves usability and safety (dry-run for cleanup, config-driven ping target, report path handling).

## Changes

- Add `Config.psm1` to load `config.json` and expose `Get-ASUConfig`, `Get-ASUReportPath`, `Get-ASULoggingLevel`.
- Remove reliance on global variables for config; modules call accessor functions instead.
- Add comment-based help for exported functions and minor tooling fixes.
- Make cleanup interactive with a dry-run option.
- Replace embedded JSON in modules with `config.json` at repo root.
- Fix PSScriptAnalyzer warnings and trim trailing whitespace.

## Remaining notes

- No behavioral changes to menus; interactive `Write-Host` output preserved for UI.
- If you want stricter analyzer enforcement, we can add full help comments for all functions and re-enable rules.

## Testing

- `tools/test_imports.ps1` imports all modules successfully.
- `tools/parse_all.ps1` reports `ALL_PARSE_OK`.
- `tools/run_analyzer.ps1` executed locally; analyzer findings addressed or documented.

Please review the `Config.psm1` API and let me know if you'd prefer a different shape for configuration values.
