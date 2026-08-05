@echo off
title Aaron System Utility
cd /d "%~dp0"

where powershell >nul 2>&1
if %errorlevel% neq 0 (
    echo PowerShell not found. Windows 10/11 required.
    pause
    exit /b 1
)

powershell -NoProfile -ExecutionPolicy Bypass -Command ^
  "Start-Process powershell -ArgumentList '-NoProfile -ExecutionPolicy Bypass -File \"%~dp0ASU.ps1\"' -Verb RunAs"