@echo off
setlocal enabledelayedexpansion
title WealthView Dashboard

REM ============================================================
REM  WealthView Dashboard - Lanceur Windows (double-clic)
REM  URL : http://localhost:8080/WealthView-Dashboard/
REM  v2.0.6 : retry de kill + verification port + alertes claires
REM ============================================================

set PORT=8080
set APP_NAME=WealthView-Dashboard
set APP_DIR=%~dp0
if "%APP_DIR:~-1%"=="\" set APP_DIR=%APP_DIR:~0,-1%

echo ===================================================
echo   WealthView Dashboard
echo   URL : http://localhost:%PORT%/%APP_NAME%/
echo ===================================================
echo.

REM --- Verification de la structure ---
if not exist "%APP_DIR%\index.html" (
    echo ERREUR : index.html introuvable dans :
    echo   %APP_DIR%
    echo.
    echo Ce fichier doit rester dans le dossier WealthView-Dashboard.
    echo.
    pause
    exit /b 1
)

REM --- Detection de Python (py launcher prioritaire, puis python) ---
set PY_CMD=
where py >nul 2>nul
if %errorlevel%==0 (
    py -3 --version >nul 2>nul
    if !errorlevel!==0 set PY_CMD=py -3
)
if "!PY_CMD!"=="" (
    where python >nul 2>nul
    if !errorlevel!==0 (
        python --version >nul 2>nul
        if !errorlevel!==0 set PY_CMD=python
    )
)

if "!PY_CMD!"=="" (
    echo.
    echo ====================================================
    echo   ERREUR : Python 3 n'est pas installe sur ce poste.
    echo ====================================================
    echo.
    echo   Solution :
    echo     1. Telecharger Python 3 : https://www.python.org/downloads/
    echo     2. COCHER la case [x] Add Python to PATH
    echo     3. Relancer ce fichier (double-clic).
    echo.
    echo   Alternative : installer Python 3 via le Microsoft Store.
    echo.
    pause
    exit /b 1
)

REM --- Tuer tout serveur existant sur le port 8080 (5 essais max) ---
echo Verification du port %PORT%...
set ATTEMPT=0
:KILL_LOOP
set /a ATTEMPT+=1
set BUSY=0
for /f "tokens=5" %%a in ('netstat -aon ^| findstr ":%PORT% " ^| findstr "LISTENING"') do (
    set BUSY=1
    echo   Kill PID %%a ^(essai !ATTEMPT!^)
    taskkill /F /PID %%a >nul 2>nul
)
if !BUSY!==1 (
    if !ATTEMPT! lss 5 (
        timeout /t 1 /nobreak >nul
        goto KILL_LOOP
    )
)

REM --- Verification finale : le port doit etre libre ---
set STILL_BUSY=0
for /f "tokens=5" %%a in ('netstat -aon ^| findstr ":%PORT% " ^| findstr "LISTENING"') do (
    set STILL_BUSY=1
    set BUSY_PID=%%a
)
if !STILL_BUSY!==1 (
    echo.
    echo ====================================================
    echo   ERREUR : port %PORT% toujours occupe par PID !BUSY_PID!
    echo ====================================================
    echo.
    echo   Solution : ouvrir PowerShell et executer :
    echo     Stop-Process -Id !BUSY_PID! -Force
    echo.
    echo   Ou redemarrer le PC et relancer ce fichier.
    echo.
    pause
    exit /b 1
)
echo   Port %PORT% libre.

REM --- Dossier de service isole (ne sert QUE WealthView-Dashboard) ---
set SERVE_ROOT=%TEMP%\wealthview-serve-%RANDOM%%RANDOM%
mkdir "%SERVE_ROOT%" >nul 2>nul
mklink /J "%SERVE_ROOT%\%APP_NAME%" "%APP_DIR%" >nul 2>nul
if %errorlevel% neq 0 (
    echo Avertissement : jonction NTFS impossible. Mode simplifie.
    rmdir "%SERVE_ROOT%" 2>nul
    REM Fallback : servir depuis le parent du dossier (expose les fichiers voisins)
    for %%I in ("%APP_DIR%\..") do set SERVE_ROOT=%%~fI
)

echo.
echo   Python detecte : !PY_CMD!
echo   Dossier        : %APP_DIR%
echo   Serve root     : %SERVE_ROOT%
echo   Fermer cette fenetre pour arreter le serveur.
echo.

REM --- Ouvrir le navigateur apres 2 secondes ---
start "" /b cmd /c "timeout /t 2 /nobreak >nul & start http://localhost:%PORT%/%APP_NAME%/"

REM --- Lancer le serveur HTTP Python (foreground) ---
cd /d "%SERVE_ROOT%"
!PY_CMD! -m http.server %PORT%

REM --- Nettoyage des liens temporaires a l'arret ---
if exist "%SERVE_ROOT%\%APP_NAME%" rmdir "%SERVE_ROOT%\%APP_NAME%" 2>nul
if exist "%SERVE_ROOT%" if not "%SERVE_ROOT%"=="%APP_DIR%\.." rmdir "%SERVE_ROOT%" 2>nul
endlocal
