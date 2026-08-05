# 🛠️ Aaron System Utility (ASU)

[![PowerShell](https://img.shields.io/badge/PowerShell-5.1-blue)](https://github.com/AStrasler/Aaron-System-Utility)
[![Windows](https://img.shields.io/badge/Windows-10%20%2F%2011-0078D4)](https://github.com/AStrasler/Aaron-System-Utility)
[![License](https://img.shields.io/badge/License-MIT-green)](License)
[![Version](https://img.shields.io/badge/Version-1.0.1-orange)](VERSION)

A clean, modular Windows maintenance & diagnostics utility written in **PowerShell 5.1**.

**Administrator rights are required for all usable features.**

## ✨ Features

| Module | What it does |
|--------|--------------|
| 🔋 **Battery** | Battery status + HTML report |
| 🧹 **Cleanup** | Safe cleanup of temp files older than 1 day |
| 🧠 **Memory** | RAM usage + top memory consumers |
| 🌐 **Network** | Local/public IP, gateway, connectivity test |
| 💾 **Storage** | Disk health + free-space percentage |
| 🚀 **Startup** | List startup applications |
| 🔄 **Updates** | Pending Windows Update count & titles |
| 🔧 **Windows Repair** | SFC, DISM RestoreHealth, schedule CHKDSK |
| 📊 **Reports** | Timestamped HTML system report |

Also includes console + daily file logging, light/dark theme support, and portable launch.

## 📋 Requirements

- Windows 10 or Windows 11  
- PowerShell 5.1 (included with Windows)  
- **Administrator rights required for all usable features**

## 🚀 Quick Start

1. Clone or download the repo  
2. Double-click **`ASU.bat`** (requests elevation automatically)  
3. Pick an option from the menu  

**Alternative (already elevated PowerShell):**

```powershell
powershell -ExecutionPolicy Bypass -File .\ASU.ps1
Non-elevated / keep window open: use launcher.bat
📁 Project Structure
textAaron-System-Utility/
├── ASU.bat / ASU.ps1 / launcher.bat
├── *.psm1                  # Feature modules
├── settings.json
├── VERSION
├── CHANGELOG.md
├── License
├── tools/                  # Verification scripts
├── Logs/                   # Created at runtime
└── Reports/                # Created at runtime
⚙️ Configuration
Edit settings.json to change logging level and health thresholds.
📄 License
MIT License — see License.

Made with ❤️ for power users and sysadmins.
Contributions, issues, and feature requests are welcome! 🙌