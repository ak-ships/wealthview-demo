@echo off
title WealthView Dashboard
set PORT=8080
cd /d "%~dp0"

echo ===================================================
echo   WealthView Dashboard
echo   http://localhost:%PORT%/
echo ===================================================
echo   Press Ctrl+C to stop.
echo.

start "" /b cmd /c "timeout /t 2 /nobreak >nul & start http://localhost:%PORT%/"

where py >nul 2>nul && (py -3 -m http.server %PORT%) || (python -m http.server %PORT%)
