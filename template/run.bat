@echo off
set "DIR=%~dp0"
powershell -NoProfile -ExecutionPolicy Bypass -Command "Set-Location '%DIR%'; Get-ChildItem '*.ps1' | Unblock-File -Confirm:$false -ErrorAction SilentlyContinue; & '.\portablemc_run.ps1'"
