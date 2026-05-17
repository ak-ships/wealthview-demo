#!/bin/bash
# WealthView Dashboard - Lanceur macOS (double-clic)
# URL : http://localhost:8080/WealthView-Dashboard/
#
# Ce fichier est le SEUL lanceur a utiliser sur Mac :
# double-cliquer dans le Finder. Une fenetre Terminal s'ouvre,
# le serveur demarre, le navigateur s'ouvre automatiquement.
# Pour arreter : fermer la fenetre Terminal.

PORT=8080
APP_NAME="WealthView-Dashboard"
APP_DIR="$(cd "$(dirname "$0")" && pwd)"
LOG="$HOME/Library/Logs/WealthView.log"
mkdir -p "$(dirname "$LOG")"

log() { echo "[$(date '+%H:%M:%S')] $*" >> "$LOG"; }
log "=== Launch start ==="

clear
echo "============================================================"
echo "  WealthView Dashboard"
echo "  URL : http://localhost:$PORT/$APP_NAME/"
echo "============================================================"
echo ""

# 1. Verification de la structure du dossier
if [ ! -f "$APP_DIR/index.html" ]; then
    echo "ERREUR : index.html introuvable dans :"
    echo "  $APP_DIR"
    echo ""
    echo "Ce fichier doit rester dans le dossier WealthView-Dashboard."
    log "ERROR: index.html not found in $APP_DIR"
    read -p "Appuyer sur Entree pour fermer..."
    exit 1
fi

# 2. Detection de Python 3
PYTHON_BIN=""
for candidate in /usr/bin/python3 /usr/local/bin/python3 /opt/homebrew/bin/python3 python3; do
    if command -v "$candidate" >/dev/null 2>&1; then
        PYTHON_BIN="$candidate"
        break
    fi
done
if [ -z "$PYTHON_BIN" ]; then
    echo "ERREUR : Python 3 introuvable."
    echo ""
    echo "Solution : ouvrir Terminal et executer :"
    echo "  xcode-select --install"
    log "ERROR: python3 not found"
    read -p "Appuyer sur Entree pour fermer..."
    exit 1
fi

# 3. Reparation des permissions et des xattr (au cas ou)
chmod +x "$APP_DIR/Lancer-WealthView.command" 2>/dev/null
chmod +x "$APP_DIR/start.command" 2>/dev/null
chmod +x "$APP_DIR/start.sh" 2>/dev/null
xattr -d com.apple.quarantine "$APP_DIR/Lancer-WealthView.command" 2>/dev/null

# 4. Liberer le port 8080 (boucle de kill, 5 essais)
echo "[1/3] Verification du port $PORT..."
for attempt in 1 2 3 4 5; do
    OLD_PIDS=$(lsof -ti :$PORT 2>/dev/null)
    if [ -z "$OLD_PIDS" ]; then
        echo "      Port libre."
        break
    fi
    echo "      Kill PID $OLD_PIDS (essai $attempt)..."
    log "Kill PIDs $OLD_PIDS attempt $attempt"
    echo "$OLD_PIDS" | xargs kill -9 2>/dev/null
    sleep 1
done
if lsof -ti :$PORT >/dev/null 2>&1; then
    BUSY_PIDS=$(lsof -ti :$PORT 2>/dev/null | tr '\n' ' ')
    echo ""
    echo "ECHEC : port $PORT toujours occupe (PID : $BUSY_PIDS)."
    echo "Redemarrer le Mac et relancer ce fichier."
    log "ERROR: port $PORT still busy: $BUSY_PIDS"
    read -p "Appuyer sur Entree pour fermer..."
    exit 1
fi

# 5. Creer un dossier de service isole (expose uniquement WealthView-Dashboard)
echo ""
echo "[2/3] Preparation du serveur..."
SERVE_ROOT="$(mktemp -d -t wealthview-serve-XXXXXX)"
ln -s "$APP_DIR" "$SERVE_ROOT/$APP_NAME"
log "SERVE_ROOT=$SERVE_ROOT"
echo "      Dossier temporaire : $SERVE_ROOT"

cleanup() {
    rm -rf "$SERVE_ROOT" 2>/dev/null
    log "=== Launch end ==="
    echo ""
    echo "Serveur arrete. Cette fenetre peut etre fermee."
}
trap cleanup EXIT INT TERM

# 6. Ouvrir le navigateur apres que le serveur ecoute
(
    sleep 2
    for i in 1 2 3 4 5; do
        if curl -sf -o /dev/null "http://localhost:$PORT/$APP_NAME/index.html"; then
            open "http://localhost:$PORT/$APP_NAME/"
            exit 0
        fi
        sleep 0.5
    done
    open "http://localhost:$PORT/$APP_NAME/"
) &

# 7. Lancer le serveur HTTP Python en foreground
echo ""
echo "[3/3] Demarrage du serveur..."
echo ""
echo "============================================================"
echo "  Dashboard accessible sur :"
echo "  http://localhost:$PORT/$APP_NAME/"
echo ""
echo "  Pour ARRETER le serveur :"
echo "  fermer cette fenetre Terminal (ou Ctrl+C)."
echo "============================================================"
echo ""

cd "$SERVE_ROOT"
log "Starting: $PYTHON_BIN -m http.server $PORT"
"$PYTHON_BIN" -m http.server "$PORT" 2>&1 | tee -a "$LOG"
