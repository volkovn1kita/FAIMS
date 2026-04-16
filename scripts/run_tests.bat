@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

set "SCRIPT_DIR=%~dp0"
set "PROJECT_ROOT=%SCRIPT_DIR%.."
set "FRONTEND_DIR=%PROJECT_ROOT%\frontend"

if not "%API_HOST%"=="" (
    set "HOST_IP=%API_HOST%"
    goto :found
)

for /f "tokens=2 delims=:" %%a in ('ipconfig ^| findstr /i "IPv4" ^| findstr "192.168.1. 192.168.0. 10."') do (
    set "CANDIDATE=%%a"
    set "CANDIDATE=!CANDIDATE: =!"
    if "!HOST_IP!"=="" set "HOST_IP=!CANDIDATE!"
)

if not "%HOST_IP%"=="" goto :found

for /f "tokens=2 delims=:" %%a in ('ipconfig ^| findstr /i "IPv4" ^| findstr /v "127.0.0.1 169.254. 192.168.56."') do (
    set "CANDIDATE=%%a"
    set "CANDIDATE=!CANDIDATE: =!"
    if "!HOST_IP!"=="" set "HOST_IP=!CANDIDATE!"
)

:found
if "%HOST_IP%"=="" (
    echo ERROR: Could not detect local IP address.
    echo Please set it manually:
    echo   set API_HOST=your.ip.address
    echo   scripts\run_tests.bat
    exit /b 1
)

if "%API_PORT%"=="" set "API_PORT=5076"

echo ============================================
echo  FAIMS Integration Test Runner
echo ============================================
echo  API Host: %HOST_IP%
echo  API Port: %API_PORT%
echo  API URL:  http://%HOST_IP%:%API_PORT%/api
echo ============================================

cd /d "%FRONTEND_DIR%"

flutter test integration_test/app_test.dart ^
    --dart-define=API_HOST=%HOST_IP% ^
    --dart-define=API_PORT=%API_PORT% ^
    --dart-define=API_BASE_URL=http://%HOST_IP%:%API_PORT%/api ^
    %* 2>&1 | powershell -Command "$input | Tee-Object -FilePath 'test_results.txt'"
