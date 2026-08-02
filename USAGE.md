Aaron System Utility - Quick Usage

Manual run:

Open PowerShell (optionally elevated) and run:

```powershell
cd <path-to-repo>
powershell -NoProfile -ExecutionPolicy Bypass -File .\ASU.ps1
```

Non-interactive maintenance (cleanup + report):

```powershell
cd <path-to-repo>
powershell -NoProfile -ExecutionPolicy Bypass -File .\ASU_maintenance.ps1
```

Dry-run to preview cleanup actions:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\ASU_maintenance.ps1 -DryRun
```

Register a daily scheduled task (runs at 03:00 by default):

```powershell
cd <path-to-repo>
powershell -NoProfile -ExecutionPolicy Bypass -File .\schedule_task.ps1
```

Notes:
- `ASU.ps1` is the interactive launcher and requires elevation due to `#Requires -RunAsAdministrator`.
- `ASU_maintenance.ps1` is designed to run without elevation for typical user-level cleanup and report generation.
- Check the `Reports/` folder for generated HTML reports and the `ASU_Maintenance.log` when `-LogToFile` is used.
