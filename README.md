# Aaron System Assistant (ASA)

[![PowerShell](https://img.shields.io/badge/PowerShell-5.1-blue)](https://github.com/AStrasler/Aaron-System-Utility)
[![Windows](https://img.shields.io/badge/Windows-10%20%2F%2011-0078D4)](https://github.com/AStrasler/Aaron-System-Utility)
[![License](https://img.shields.io/badge/License-MIT-green)](License)
[![Version](https://img.shields.io/badge/Version-2.0.0--dev-orange)](VERSION)

Modular Windows maintenance assistant for **PowerShell 5.1**.

**Administrator rights are required for all usable features.**

## Features

| Area | What it does |
| --- | --- |
| Battery | Status + HTML report |
| Cleanup | Temp files older than 1 day |
| Memory | Usage + top processes |
| Network | IP, gateway, connectivity |
| Storage | Disk health + free space |
| Startup | List / optimize Run-key items |
| Updates | Pending updates |
| Install and Restart | Download/install updates and reboot |
| Windows Repair | SFC, DISM, CHKDSK guidance |
| Reports | HTML system report |

Also: light/dark console theme, portable launch, menu **or** plain-English requests (IntentEngine).

## Requirements

- Windows 10 or 11
- PowerShell 5.1
- **Administrator rights for all usable features**

## Quick Start

1. Clone or download the repo
2. Double-click **`ASA.bat`** (requests elevation)
3. Use a menu number **or** type a request (e.g. `check memory`, `clean temp`)

Already elevated PowerShell:

    powershell -ExecutionPolicy Bypass -File .\ASA.ps1

Non-elevated / keep window open: `launcher.bat`

## Project Structure

    Aaron-System-Utility/
    ├── ASA.bat / ASA.ps1 / launcher.bat
    ├── IntentEngine.psm1
    ├── LicenseCheck.psm1
    ├── Utilities.psm1
    ├── *.psm1                  # Feature modules
    ├── settings.json
    ├── VERSION
    ├── CHANGELOG.md
    ├── License
    ├── tools/
    ├── Logs/                   # Runtime
    └── Reports/                # Runtime

## Configuration

Edit `settings.json` for logging level and health thresholds.

## License

MIT License — see [License](License).

v2.0.0 commercial / dual-license ideas are planning only (see GitHub issues). This tree remains MIT until a formal license change is published.
