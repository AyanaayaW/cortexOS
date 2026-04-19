@echo off
echo.
echo  Launching CortexOS installer...
echo.
powershell -ExecutionPolicy Bypass -File "%~dp0install.ps1"
pause
