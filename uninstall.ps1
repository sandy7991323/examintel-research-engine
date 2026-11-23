# Uninstall ExamIntel Research Engine Skill from Antigravity global skills
$ErrorActionPreference = "Stop"

$targetDir = Join-Path $HOME ".gemini\config\skills\examintel-research-engine"

Write-Host "Uninstalling ExamIntel Research Engine from global skills..." -ForegroundColor Cyan

if (Test-Path -Path $targetDir) {
    Remove-Item -Path $targetDir -Recurse -Force
    Write-Host "`n[SUCCESS] Removed from: $targetDir" -ForegroundColor Green
    Write-Host "ExamIntel Research Engine is now completely separated and isolated." -ForegroundColor Green
    Write-Host "Your standalone project files remain safe in: $PSScriptRoot" -ForegroundColor Green
    Write-Host "Whenever you want to use it again, simply run: .\install.ps1" -ForegroundColor Yellow
} else {
    Write-Host "`n[INFO] Skill was not installed in $targetDir" -ForegroundColor Yellow
}
