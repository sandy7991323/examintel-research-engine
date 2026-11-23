# Install ExamIntel Research Engine Skill into Antigravity
$ErrorActionPreference = "Stop"

$sourceDir = $PSScriptRoot
$targetDir = Join-Path $HOME ".gemini\config\skills\examintel-research-engine"

Write-Host "Installing ExamIntel Research Engine..." -ForegroundColor Cyan
Write-Host "Source: $sourceDir"
Write-Host "Target: $targetDir"

if (-not (Test-Path -Path (Split-Path $targetDir -Parent))) {
    New-Item -ItemType Directory -Path (Split-Path $targetDir -Parent) -Force | Out-Null
}

# Copy files recursively
Copy-Item -Path $sourceDir -Destination $targetDir -Recurse -Force

Write-Host "`n[SUCCESS] ExamIntel Research Engine installed successfully!" -ForegroundColor Green
Write-Host "Antigravity will now detect and load this skill when needed." -ForegroundColor Green
Write-Host "To uninstall later, simply run: .\uninstall.ps1" -ForegroundColor Yellow
