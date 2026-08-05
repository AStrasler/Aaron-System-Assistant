# Changelog

All notable changes to Aaron System Utility (ASU) are documented in this file.

## [1.0.1] - 2026-08-05

### Fixed
- Restored correct content to every module file (previous commit had fully swapped contents).
- Implemented missing `Updates.psm1` and `WindowsRepair.psm1`.
- Corrected free-space percentage calculation in Storage module (was using Free/Used instead of Free/Total).
- Added missing `Pause` helper required by all modules.
- Restored valid `settings.json`, `LICENSE`, `VERSION`, and this changelog.
- Hardened temporary-file cleanup to skip files newer than 1 day and locked files.
- Made module import path handling and logging more robust.

### Changed
- Logging now writes both to console and to daily files under `Logs/`.
- Network public-IP lookup uses a 5-second timeout.
- Main script version banner updated to 1.0.1.

## [1.0.0] - 2026-07-11

### Added
- Initial modular structure.
- Core modules and menu-driven interface.
- Basic logging and report generation.