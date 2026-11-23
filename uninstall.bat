@echo off
echo Uninstalling ExamIntel Research Engine Skill from Antigravity...
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0uninstall.ps1"
pause
