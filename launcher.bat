@echo off
title Aaron System Assistant
cd /d "%~dp0"
powershell -NoProfile -NoExit -ExecutionPolicy Bypass -File "%~dp0ASA.ps1"