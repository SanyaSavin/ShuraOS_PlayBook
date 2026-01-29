# ============================================================================
# Remove-Defender.ps1 - Полное удаление Windows Defender
# ============================================================================
# Этот скрипт полностью удаляет Windows Defender из системы.
# ВНИМАНИЕ: После удаления восстановление возможно только через
# переустановку Windows или восстановление из резервной копии.
# ============================================================================

$ErrorActionPreference = 'SilentlyContinue'

Write-Host "============================================"
Write-Host "Removing Windows Defender completely..."
Write-Host "============================================"

# Функция для безопасного изменения реестра
function Set-RegistryValue {
    param(
        [string]$Path,
        [string]$Name,
        [object]$Value,
        [string]$Type = "DWord"
    )
    
    try {
        if (!(Test-Path $Path)) {
            New-Item -Path $Path -Force | Out-Null
        }
        Set-ItemProperty -Path $Path -Name $Name -Value $Value -Type $Type -Force -ErrorAction SilentlyContinue
    }
    catch {
        # Игнорируем ошибки доступа
    }
}

# ============================================================================
# Отключение через Group Policy
# ============================================================================

Write-Host "Setting Group Policy to disable Defender..."

Set-RegistryValue -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender" -Name "DisableAntiSpyware" -Value 1
Set-RegistryValue -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender" -Name "DisableAntiVirus" -Value 1
Set-RegistryValue -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" -Name "DisableRealtimeMonitoring" -Value 1
Set-RegistryValue -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" -Name "DisableBehaviorMonitoring" -Value 1
Set-RegistryValue -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" -Name "DisableOnAccessProtection" -Value 1
Set-RegistryValue -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" -Name "DisableScanOnRealtimeEnable" -Value 1
Set-RegistryValue -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" -Name "DisableIOAVProtection" -Value 1

# ============================================================================
# Попытка отключить Defender через Set-MpPreference
# ============================================================================

Write-Host "Attempting to disable Defender via Set-MpPreference..."

try {
    Set-MpPreference -DisableRealtimeMonitoring $true -ErrorAction SilentlyContinue
    Set-MpPreference -DisableBehaviorMonitoring $true -ErrorAction SilentlyContinue
    Set-MpPreference -DisableOnAccessProtection $true -ErrorAction SilentlyContinue
    Set-MpPreference -DisableScanOnRealtimeEnable $true -ErrorAction SilentlyContinue
}
catch {
    Write-Host "Note: Some Set-MpPreference commands may have failed"
}

# ============================================================================
# Удаление компонентов через DISM
# ============================================================================

Write-Host "Removing Windows Defender features via DISM..."

$dismFeatures = @(
    "Windows-Defender",
    "Windows-Defender-Features",
    "Windows-Defender-GUI",
    "Windows-Defender-ApplicationGuard"
)

foreach ($feature in $dismFeatures) {
    try {
        $result = & dism.exe /Online /Disable-Feature /FeatureName:$feature /Remove /NoRestart 2>&1
        Write-Host "DISM $feature : Done"
    }
    catch {
        Write-Host "DISM $feature : Skipped"
    }
}

# ============================================================================
# Удаление Windows Security App (SecHealthUI)
# ============================================================================

Write-Host "Removing Windows Security app..."

try {
    Get-AppxPackage -AllUsers *SecHealthUI* | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
    Get-AppxProvisionedPackage -Online | Where-Object {$_.PackageName -like "*SecHealthUI*"} | Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue
}
catch {
    Write-Host "Note: Windows Security app removal may have failed"
}

# ============================================================================
# Удаление запланированных задач
# ============================================================================

Write-Host "Removing Defender scheduled tasks..."

$defenderTasks = @(
    "\Microsoft\Windows\Windows Defender\Windows Defender Cache Maintenance",
    "\Microsoft\Windows\Windows Defender\Windows Defender Cleanup",
    "\Microsoft\Windows\Windows Defender\Windows Defender Scheduled Scan",
    "\Microsoft\Windows\Windows Defender\Windows Defender Verification"
)

foreach ($task in $defenderTasks) {
    try {
        Unregister-ScheduledTask -TaskName $task -Confirm:$false -ErrorAction SilentlyContinue
    }
    catch {
        # Игнорируем ошибки
    }
}

# ============================================================================
# Удаление автозапуска
# ============================================================================

Write-Host "Removing SecurityHealth autostart..."

try {
    Remove-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" -Name "SecurityHealth" -Force -ErrorAction SilentlyContinue
}
catch {
    # Игнорируем ошибки
}

# ============================================================================
# Скрытие иконки в системном трее
# ============================================================================

Write-Host "Hiding system tray icon..."

Set-RegistryValue -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender Security Center\Systray" -Name "HideSystray" -Value 1

# ============================================================================
# Отключение SmartScreen
# ============================================================================

Write-Host "Disabling SmartScreen..."

Set-RegistryValue -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "EnableSmartScreen" -Value 0
Set-RegistryValue -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" -Name "SmartScreenEnabled" -Value "Off" -Type "String"

Write-Host "============================================"
Write-Host "Windows Defender removal completed."
Write-Host "A system restart may be required."
Write-Host "============================================"

exit 0
