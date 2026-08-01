<# 
.SYNOPSIS
	Cleanup module for ASU
#>

function Show-CleanupMenu {
	Clear-Host
	Write-Host "=== System Cleanup ===" -ForegroundColor Cyan
	Write-Host "Cleaning temporary files..." -ForegroundColor Yellow
	Write-Host "This will remove files under $env:TEMP. Choose an option: [Y]es [N]o [D]ry-run" -ForegroundColor Yellow
	$choice = Read-Host "Proceed? (Y/N/D)" 
	switch ($choice.ToUpper()) {
		'D' {
			Write-Host "Dry run: showing actions (no files will be deleted)." -ForegroundColor Cyan
			Remove-Item -Path "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue -WhatIf
			Pause
			Show-MainMenu
			return
		}
		'Y' {
			Write-Host "Performing cleanup..." -ForegroundColor Yellow
			Remove-Item -Path "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue
			Write-Host "Temp files cleaned." -ForegroundColor Green
		}
		default {
			Write-Host "Cleanup canceled." -ForegroundColor Yellow
			Pause
			Show-MainMenu
			return
		}
	}
    
	Write-ASULog "System cleanup performed" -Level "Info"
	Pause
	Show-MainMenu
}

Export-ModuleMember -Function Show-CleanupMenu