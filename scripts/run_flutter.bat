@echo off
REM Automatically detects the host machine's local IP address
REM and runs the Flutter app with the correct API_HOST.
REM
REM Usage:
REM   scripts\run_flutter.bat [additional flutter run arguments]
REM
REM Override IP manually:
REM   set API_HOST=192.168.1.105
REM   scripts\run_flutter.bat

setlocal enabledelayedexpansion

set "SCRIPT_DIR=%~dp0"
set "PROJECT_ROOT=%SCRIPT_DIR%.."
set "FRONTEND_DIR=%PROJECT_ROOT%\frontend"

REM Use manually set API_HOST if provided
if not "%API_HOST%"=="" (
    set "HOST_IP=%API_HOST%"
    goto :found
)

REM Try to find real LAN IP (192.168.0.x or 192.168.1.x or 10.x.x.x)
for /f "tokens=2 delims=:" %%a in ('ipconfig ^| findstr /i "IPv4" ^| findstr "192.168.1. 192.168.0. 10."') do (
    set "CANDIDATE=%%a"
    set "CANDIDATE=!CANDIDATE: =!"
    if "!HOST_IP!"=="" set "HOST_IP=!CANDIDATE!"
)

if not "%HOST_IP%"=="" goto :found

REM Fallback: take any non-virtual IP
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
    echo   scripts\run_flutter.bat
    exit /b 1
)

if "%API_PORT%"=="" set "API_PORT=5076"

echo ============================================
echo  FAIMS Flutter App Launcher
echo ============================================
echo  API Host: %HOST_IP%
echo  API Port: %API_PORT%
echo  API URL:  http://%HOST_IP%:%API_PORT%/api
echo ============================================
echo.
echo  Wrong IP? Run:  set API_HOST=x.x.x.x
echo ============================================

cd /d "%FRONTEND_DIR%"

flutter run --dart-define=API_HOST=%HOST_IP% --dart-define=API_PORT=%API_PORT% --dart-define=API_BASE_URL=http://%HOST_IP%:%API_PORT%/api %*
