# Aaron System Utility (ASU)

[![PowerShell](https://img.shields.io/badge/PowerShell-5.1-blue)](https://github.com/AStrasler/Aaron-System-Utility)
[![Windows](https://img.shields.io/badge/Windows-11-0078D4)](https://github.com/AStrasler/Aaron-System-Utility)
[![License](https://img.shields.io/badge/License-MIT-green)](LICENSE)

A professional, modular Windows maintenance and diagnostics utility written in **PowerShell 5.1**.

## ✨ Features

- **Hardware Diagnostics** — CPU, GPU, BIOS, motherboard
- **Memory Analysis** — Usage, top processes, pressure
- **Storage Health** — SMART, TRIM, free space
- **Startup Management** — List & categorize
- **Network Diagnostics** — IP, DNS, connectivity tests
- **Battery Analysis** — Health report
- **Windows Repair** — SFC, DISM, CHKDSK
- **Cleanup & Updates**
- **HTML Reports** + Logging

## 🚀 Quick Start

1. Download the latest release or clone the repo.
2. Extract and run `ASU.bat`. If you plan to use repair features (SFC/DISM/CHKDSK), run the launcher with Administrator rights (Right-click → Run as administrator).
3. Use the menu-driven interface.

## 📁 Project Structure

Aaron-System-Utility/
- ASU.bat              — Launcher (double-click to open PowerShell and run ASU)
- ASU.ps1              — Main script and interactive menu
- *.psm1               — Module files (Battery.psm1, Cleanup.psm1, Memory.psm1, Network.psm1, Storage.psm1, Updates.psm1, Startup.psm1, Reports.psm1, Utilities.psm1, WindowsRepair.psm1)
- config.json          — Optional configuration file at the repository root (see Configuration)
- Reports/             — Generated HTML reports (created at runtime)
- tools/               — Utility scripts for testing and linting
- README.md
- LICENSE

## Requirements

- Windows 10 / 11
- PowerShell 5.1 (pre-installed)
- Administrator rights for repairs
 
## Configuration

- The utility reads `config.json` from the repository root. You can change `LoggingLevel` (`Info`, `Warning`, `Error`) and `ReportPath` in that file to control behavior and output locations. Example:

```json
{
	"LoggingLevel": "Info",
	"ReportPath": "Reports",
	"PingTarget": "8.8.8.8"
}
```

## Safety and Usability

- Cleanup operations now prompt for confirmation and support a dry-run option (select `D` at the prompt) so you can preview destructive actions.
- The launcher and README clearly indicate Administrator rights are required for repair operations; use the provided `launcher.bat` or create an elevated shortcut.

## License

MIT License — feel free to fork and contribute.

---

**Made with ❤️ for power users and sysadmins.**  
Contributions, issues, and feature requests welcome!

## 📂 Double-click Launcher

If you want to open ASU by double-clicking a file, use the provided `launcher.bat` or create a shortcut. `launcher.bat` does not auto-elevate; to run repair tasks you must run the launcher as Administrator.

Contents of `launcher.bat`:

```bat
@echo off
REM Simple double-click launcher for Aaron-System-Utility
SET SCRIPT_DIR=%~dp0
powershell -NoProfile -NoExit -ExecutionPolicy Bypass -File "%SCRIPT_DIR%ASU.ps1"
```

## 📌 Desktop / Start Menu Shortcut

1. Right-click the Desktop and choose New → Shortcut.
2. For Target, paste:

```
powershell -NoExit -ExecutionPolicy Bypass -File "C:\Path\To\Aaron-System-Utility\ASU.ps1"
```

3. Set "Start in" to the repo folder and finish. If the script needs admin rights, enable "Run as administrator" in Shortcut > Advanced.

## ⚙️ Quick Troubleshooting

- If PowerShell blocks the script, run once in an elevated PowerShell:

```powershell
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned -Force
```

- Or launch without changing policies:

```powershell
powershell -ExecutionPolicy Bypass -File .\ASU.ps1
```

