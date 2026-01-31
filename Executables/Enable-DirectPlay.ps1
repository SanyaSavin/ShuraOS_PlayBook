# ============================================================================
# Enable-DirectPlay.ps1 - Включение DirectPlay в компонентах Windows
# ============================================================================
# DirectPlay - это компонент "Legacy Components" для совместимости со старыми играми
# ============================================================================

$ErrorActionPreference = 'SilentlyContinue'

Write-Host "============================================"
Write-Host "Enabling DirectPlay (Legacy Components)..."
Write-Host "============================================"

# Включаем компонент DirectPlay через DISM
DISM /Online /Enable-Feature /FeatureName:"DirectPlay" /All /Quiet

if ($LASTEXITCODE -eq 0) {
    Write-Host "DirectPlay enabled successfully!" -ForegroundColor Green
} else {
    Write-Host "Note: DirectPlay may already be enabled or not available on this system" -ForegroundColor Yellow
}

Write-Host "============================================"
