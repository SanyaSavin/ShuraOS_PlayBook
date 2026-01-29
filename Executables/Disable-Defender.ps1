# ============================================================================
# Disable-Defender.ps1 - Отключение Windows Defender без удаления
# ============================================================================
# Этот скрипт отключает Windows Defender, но сохраняет приложение
# "Безопасность Windows" видимым, чтобы пользователь мог вручную
# включить защитник при необходимости.
# ============================================================================

$ErrorActionPreference = 'SilentlyContinue'

Write-Host "============================================"
Write-Host "Disabling Windows Defender..."
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

# Функция для удаления значения реестра
function Remove-RegistryValue {
    param(
        [string]$Path,
        [string]$Name
    )
    
    try {
        Remove-ItemProperty -Path $Path -Name $Name -Force -ErrorAction SilentlyContinue
    }
    catch {
        # Игнорируем ошибки
    }
}

# ============================================================================
# Отключение через Group Policy (работает без обхода Tamper Protection)
# ============================================================================

Write-Host "Setting Group Policy to disable Defender..."

# Основные политики отключения
Set-RegistryValue -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender" -Name "DisableAntiSpyware" -Value 1
Set-RegistryValue -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender" -Name "DisableAntiVirus" -Value 1

# Real-Time Protection
Set-RegistryValue -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" -Name "DisableRealtimeMonitoring" -Value 1
Set-RegistryValue -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" -Name "DisableBehaviorMonitoring" -Value 1
Set-RegistryValue -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" -Name "DisableOnAccessProtection" -Value 1
Set-RegistryValue -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" -Name "DisableScanOnRealtimeEnable" -Value 1
Set-RegistryValue -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" -Name "DisableIOAVProtection" -Value 1

# Cloud Protection
Set-RegistryValue -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Spynet" -Name "SpynetReporting" -Value 0
Set-RegistryValue -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Spynet" -Name "SubmitSamplesConsent" -Value 2
Set-RegistryValue -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\MpEngine" -Name "MpEnablePus" -Value 0

# ============================================================================
# Отключение SmartScreen
# ============================================================================

Write-Host "Disabling SmartScreen..."

Set-RegistryValue -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "EnableSmartScreen" -Value 0
Set-RegistryValue -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" -Name "SmartScreenEnabled" -Value "Off" -Type "String"

# ============================================================================
# Отключение автозапуска SecurityHealth
# ============================================================================

Write-Host "Disabling SecurityHealth autostart..."

Remove-RegistryValue -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" -Name "SecurityHealth"

# ============================================================================
# Отключение запланированных задач Defender
# ============================================================================

Write-Host "Disabling Defender scheduled tasks..."

$defenderTasks = @(
    "\Microsoft\Windows\Windows Defender\Windows Defender Cache Maintenance",
    "\Microsoft\Windows\Windows Defender\Windows Defender Cleanup",
    "\Microsoft\Windows\Windows Defender\Windows Defender Scheduled Scan",
    "\Microsoft\Windows\Windows Defender\Windows Defender Verification"
)

foreach ($task in $defenderTasks) {
    try {
        Disable-ScheduledTask -TaskName $task -ErrorAction SilentlyContinue | Out-Null
    }
    catch {
        # Игнорируем ошибки
    }
}

# ============================================================================
# ВАЖНО: Сохраняем видимость приложения "Безопасность Windows"
# ============================================================================

Write-Host "Ensuring Windows Security app remains visible..."

# Удаляем политики, которые скрывают страницы в Windows Security
Remove-RegistryValue -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender Security Center\Virus and threat protection" -Name "HideVirusAndThreatProtection"
Remove-RegistryValue -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender Security Center\Virus and threat protection" -Name "UILockdown"
Remove-RegistryValue -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender Security Center\App and Browser protection" -Name "HideAppBrowserProtection"
Remove-RegistryValue -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender Security Center\Device security" -Name "HideDeviceSecurityPage"
Remove-RegistryValue -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender Security Center\Device performance and health" -Name "HideDevicePerformanceHealth"
Remove-RegistryValue -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender Security Center\Family options" -Name "HideFamilyOptions"
Remove-RegistryValue -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender Security Center\Firewall and network protection" -Name "HideFirewallAndNetworkProtection"
Remove-RegistryValue -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender Security Center\Notifications" -Name "DisableNotifications"

# Убеждаемся, что системный трей не скрыт
Set-RegistryValue -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender Security Center\Systray" -Name "HideSystray" -Value 0

# ============================================================================
# Попытка отключить Defender через Set-MpPreference (может не сработать из-за Tamper Protection)
# ============================================================================

Write-Host "Attempting to disable Defender via Set-MpPreference..."

try {
    Set-MpPreference -DisableRealtimeMonitoring $true -ErrorAction SilentlyContinue
    Set-MpPreference -DisableBehaviorMonitoring $true -ErrorAction SilentlyContinue
    Set-MpPreference -DisableOnAccessProtection $true -ErrorAction SilentlyContinue
    Set-MpPreference -DisableScanOnRealtimeEnable $true -ErrorAction SilentlyContinue
    Set-MpPreference -DisableIOAVProtection $true -ErrorAction SilentlyContinue
    Set-MpPreference -DisableIntrusionPreventionSystem $true -ErrorAction SilentlyContinue
    Set-MpPreference -DisableScriptScanning $true -ErrorAction SilentlyContinue
    Set-MpPreference -SubmitSamplesConsent 2 -ErrorAction SilentlyContinue
    Set-MpPreference -MAPSReporting 0 -ErrorAction SilentlyContinue
}
catch {
    Write-Host "Note: Some Set-MpPreference commands may have failed due to Tamper Protection"
}

Write-Host "============================================"
Write-Host "Windows Defender has been disabled."
Write-Host "The Windows Security app remains accessible."
Write-Host "You can manually re-enable protection if needed."
Write-Host "============================================"

exit 0
