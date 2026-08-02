# PR Summary (ready for copy into PR description)

Summary

This PR aligns module filenames with their exported functions, centralizes configuration, and improves usability and safety across the repo.

Key changes

- Add `Config.psm1` to expose `Get-ASUConfig`, `Get-ASUReportPath`, `Get-ASULoggingLevel`.
- Refactor modules to use the new accessor functions (removes hidden global config usage).
- Add comment-based help for exported `Show-*Menu` functions.
- Make `Cleanup` interactive with a dry-run option and safer defaults.
- Add tooling: `tools/run_deep_tests.ps1` (non-interactive smoke tests), `tools/run_analyzer.ps1`, `tools/parse_all.ps1` improvements.
- Add CI workflow to run import/parse/analyzer/deep-tests on Windows (`.github/workflows/ci.yml`).

Testing performed

- `tools/test_imports.ps1` imports all modules successfully.
- `tools/parse_all.ps1` reports `ALL_PARSE_OK` locally.
- `tools/run_analyzer.ps1` executed and results saved to `tools/analyzer_results.json`.
- `tools/run_deep_tests.ps1` executed; output saved to `tools/deep_test_results.json`.

Notes for reviewers

- Interactive UI behavior (`Write-Host`) is preserved for menus; logging is provided by a simple `Write-ASULog` helper.
- CI uploads the analyzer and deep-test JSON artifacts for review.
- If you'd like stricter analyzer enforcement, I can add full help comments to additional functions and re-enable specific rules.

Next steps (optional)

- Add golden-file comparisons for deep tests in CI.
- Move modules into a `Modules/` directory (requires adjusting imports in `ASU.ps1`).
