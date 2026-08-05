@echo off
title Aaron System Utility
cd /d "%~dp0"
powershell -NoProfile -NoExit -ExecutionPolicy Bypass -File "%~dp0ASU.ps1"