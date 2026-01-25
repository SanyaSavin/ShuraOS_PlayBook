@echo off
chcp 65001 >nul
color 0f

:MENU
cls
echo.
echo ╔══════════════════════════════════════════════════════════════════════════════╗
echo ║                         Менеджер Защитника Windows                           ║
echo ╚══════════════════════════════════════════════════════════════════════════════╝
echo.
echo Выберите действие:
echo.
echo 1. Оставить Защитник Windows как есть (не трогать)
echo 2. Полностью удалить Защитник Windows
echo 3. Отключить Защитник Windows (без надписи об администраторе)
echo.
echo ╔══════════════════════════════════════════════════════════════════════════════╗
echo ║ Нажмите соответствующую цифру или Esc для выхода                            ║
echo ╚══════════════════════════════════════════════════════════════════════════════╝
echo.

set /p choice="Ваш выбор (1-3): "

if "%choice%"=="1" goto OPTION1
if "%choice%"=="2" goto OPTION2
if "%choice%"=="3" goto OPTION3
if "%choice%"=="" goto MENU

:OPTION1
cls
echo.
echo ╔══════════════════════════════════════════════════════════════════════════════╗
echo ║                    Защитник Windows оставлен без изменений                    ║
echo ╚══════════════════════════════════════════════════════════════════════════════╝
echo.
echo Нажмите любую клавишу для возврата в меню...
pause >nul
goto MENU

:OPTION2
cls
echo.
echo ╔══════════════════════════════════════════════════════════════════════════════╗
echo ║                         Полное удаление Защитника...                         ║
echo ╚══════════════════════════════════════════════════════════════════════════════╝
echo.
echo Пожалуйста, подождите...
echo.

:: Полное удаление Защитника Windows
echo Отключение служб Защитника...
sc config WinDefend start= disabled >nul 2>&1
sc stop WinDefend >nul 2>&1
sc config SecurityHealthService start= disabled >nul 2>&1
sc stop SecurityHealthService >nul 2>&1
sc config wscsvc start= disabled >nul 2>&1
sc stop wscsvc >nul 2>&1

echo Удаление компонентов Защитника...
dism /online /remove-package /packagename:Microsoft-Windows-Defender-Default-Definitions-Package~31bf3856ad364e35~amd64~~.cab >nul 2>&1
dism /online /remove-package /packagename:Microsoft-Windows-Defender-Default-Definitions-Package~31bf3856ad364e35~x86~~.cab >nul 2>&1

echo Удаление политик Защитника...
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender Security Center" /f >nul 2>&1

echo Удаление значка Защитника из трея...
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v "SecurityHealth" /f >nul 2>&1

echo Очистка реестра...
reg delete "HKLM\SOFTWARE\Microsoft\Windows Defender" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Microsoft\Windows Defender Security Center" /f >nul 2>&1
reg delete "HKCU\Software\Microsoft\Windows Defender" /f >nul 2>&1
reg delete "HKCU\Software\Microsoft\Windows Defender Security Center" /f >nul 2>&1

echo.
echo ╔══════════════════════════════════════════════════════════════════════════════╗
echo ║                    Защитник Windows полностью удален!                        ║
echo ╚══════════════════════════════════════════════════════════════════════════════╝
echo.
echo Нажмите любую клавишу для возврата в меню...
pause >nul
goto MENU

:OPTION3
cls
echo.
echo ╔══════════════════════════════════════════════════════════════════════════════╗
echo ║                         Отключение Защитника...                              ║
echo ╚══════════════════════════════════════════════════════════════════════════════╝
echo.
echo Пожалуйста, подождите...
echo.

:: Отключение Защитника Windows без надписи об администраторе (компоненты остаются)
echo Настройка политик Защитника...
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender" /v "DisableAntiSpyware" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender" /v "DisableRoutinelyTakingAction" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" /v "DisableBehaviorMonitoring" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" /v "DisableOnAccessProtection" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" /v "DisableScanOnRealtimeEnable" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Reporting" /v "DisableEnhancedNotifications" /t REG_DWORD /d 1 /f >nul 2>&1

echo Скрытие значка Защитника в трея...
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender Security Center\Systray" /v "HideSystray" /t REG_DWORD /d 1 /f >nul 2>&1

echo Удаление блокировки доступа к меню безопасности...
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender Security Center" /v "UILockdown" /f >nul 2>&1
reg delete "HKCU\Software\Microsoft\Windows Defender Security Center" /v "UILockdown" /f >nul 2>&1

echo.
echo ╔══════════════════════════════════════════════════════════════════════════════╗
echo ║                    Защитник Windows отключен!                                ║
echo ║        Компоненты сохранены, меню доступно, нет надписи                       ║
echo ║                 об администраторском контроле                                 ║
echo ╚══════════════════════════════════════════════════════════════════════════════╝
echo.
echo Нажмите любую клавишу для возврата в меню...
pause >nul
goto MENU

:EXIT
cls
echo.
echo ╔══════════════════════════════════════════════════════════════════════════════╗
echo ║                              До свидания!                                    ║
echo ╚══════════════════════════════════════════════════════════════════════════════╝
echo.
timeout /t 2 >nul
exit /b 0