@echo off
chcp 65001 >nul
title Архивация в .apbx

set "ARCHIVE_NAME=ShuraOS.apbx"
set "PASSWORD=malte"

echo.
echo Создаётся %ARCHIVE_NAME%  (без скрытых файлов)
echo.

if not exist "7z.exe" (
    echo 7z.exe не найден!
    pause
    exit /b 1
)

7z.exe a -t7z "%ARCHIVE_NAME%" * ^
    -mx9 -p%PASSWORD% -mhe=on -r ^
    -x!*.bat -x!7z.exe -x!7zFM.exe ^
    -x!.* -x!**\.**

if %errorlevel% leq 1 (
    echo ✓ Готово: %ARCHIVE_NAME%
) else (
    echo ❌ Ошибка. Код: %errorlevel%
)

pause