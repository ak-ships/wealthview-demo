# WealthView Dashboard - Lanceur PowerShell (Windows)
# URL : http://localhost:8080/WealthView-Dashboard/
#
# Alternative au .bat pour environnements ou les .bat sont bloques par GPO.
# Lancement : clic droit sur ce fichier > Executer avec PowerShell
# Ou depuis PowerShell : .\Lancer-WealthView.ps1

$ErrorActionPreference = "Stop"
$PORT = 8080
$APP_NAME = "WealthView-Dashboard"
$APP_DIR = Split-Path -Parent $MyInvocation.MyCommand.Path

$Host.UI.RawUI.WindowTitle = "WealthView Dashboard"

# --- Detection de Python ---
$pyCmd = $null
$candidates = @(
    @{cmd="py"; args=@("-3", "--version")},
    @{cmd="python"; args=@("--version")},
    @{cmd="python3"; args=@("--version")}
)
foreach ($c in $candidates) {
    try {
        & $c.cmd $c.args 2>&1 | Out-Null
        if ($LASTEXITCODE -eq 0) {
            $pyCmd = $c.cmd
            $pyArgs = if ($c.cmd -eq "py") { @("-3") } else { @() }
            break
        }
    } catch {}
}

if (-not $pyCmd) {
    Write-Host ""
    Write-Host "====================================================" -ForegroundColor Red
    Write-Host "  ERREUR : Python 3 n'est pas installe." -ForegroundColor Red
    Write-Host "====================================================" -ForegroundColor Red
    Write-Host ""
    Write-Host "  Installer Python 3 depuis : https://www.python.org/downloads/"
    Write-Host "  Cocher [x] Add Python to PATH pendant l'installation."
    Write-Host ""
    Read-Host "Appuyer sur Entree pour quitter"
    exit 1
}

# --- Dossier de service isole via junction NTFS ---
$serveRoot = Join-Path $env:TEMP "wealthview-serve-$([System.IO.Path]::GetRandomFileName())"
New-Item -ItemType Directory -Path $serveRoot -Force | Out-Null
try {
    New-Item -ItemType Junction -Path (Join-Path $serveRoot $APP_NAME) -Target $APP_DIR -Force -ErrorAction Stop | Out-Null
} catch {
    # Fallback : servir depuis le parent (expose les fichiers voisins)
    Write-Warning "Jonction NTFS impossible, utilisation du dossier parent."
    $serveRoot = Split-Path -Parent $APP_DIR
}

# --- Tuer tout serveur existant sur le port ---
Get-NetTCPConnection -LocalPort $PORT -ErrorAction SilentlyContinue | ForEach-Object {
    Stop-Process -Id $_.OwningProcess -Force -ErrorAction SilentlyContinue
}

Write-Host ""
Write-Host "===================================================" -ForegroundColor Cyan
Write-Host "  WealthView Dashboard"
Write-Host "  http://localhost:$PORT/$APP_NAME/" -ForegroundColor Yellow
Write-Host "===================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "  Python    : $pyCmd"
Write-Host "  Dossier   : $APP_DIR"
Write-Host "  Fermer cette fenetre pour arreter le serveur."
Write-Host ""

# --- Ouvrir le navigateur en tache de fond ---
Start-Job -ScriptBlock {
    Start-Sleep -Seconds 2
    Start-Process "http://localhost:$using:PORT/$using:APP_NAME/"
} | Out-Null

# --- Lancer le serveur HTTP Python ---
Set-Location $serveRoot
try {
    & $pyCmd @pyArgs -m http.server $PORT
} finally {
    # Nettoyage de la junction
    Remove-Item -Path (Join-Path $serveRoot $APP_NAME) -Force -ErrorAction SilentlyContinue
    Remove-Item -Path $serveRoot -Force -ErrorAction SilentlyContinue
}
