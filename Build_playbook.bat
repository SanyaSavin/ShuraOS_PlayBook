@echo off
chcp 1251 >nul
title Archive to .apbx

set "ARCHIVE_NAME=ShuraOS.apbx"
set "PASSWORD=malte"

echo.
echo Creating %ARCHIVE_NAME% (without hidden files)...
echo.

if not exist "7z.exe" (
    echo 7z.exe not found!
    pause
    exit /b 1
)

7z a -t7z "%ARCHIVE_NAME%" * -mx9 -p%PASSWORD% -mhe=on -r -x!*.bat -x!7z.exe -x!7zFM.exe -x!.* -x!**\.**

if %errorlevel% leq 1 (
    echo ✓ Done: %ARCHIVE_NAME%
) else (
    echo ❌ Error. Code: %errorlevel%
)

pause