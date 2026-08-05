@echo off
SET SCRIPT_DIR=%~dp0
powershell -NoProfile -NoExit -ExecutionPolicy Bypass -File "%SCRIPT_DIR%ASU.ps1"