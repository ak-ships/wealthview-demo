#!/bin/bash
# WealthView Dashboard — lance un serveur HTTP local et ouvre le navigateur
# Usage : double-cliquer sur start.command (macOS) ou ./start.sh dans un terminal
# URL : http://localhost:8080/WealthView-Dashboard/

PORT=8080
APP_DIR="$(cd "$(dirname "$0")" && pwd)"
APP_NAME="WealthView-Dashboard"

# Dossier de service isolé (ne sert QUE WealthView-Dashboard, pas tout le Bureau)
SERVE_ROOT="$(mktemp -d -t wealthview-serve-XXXXXX)"
ln -s "$APP_DIR" "$SERVE_ROOT/$APP_NAME"

# Nettoyage du lien symbolique à l'arrêt du serveur (Ctrl+C)
cleanup() {
  rm -rf "$SERVE_ROOT" 2>/dev/null
  exit 0
}
trap cleanup EXIT INT TERM

# Tuer un éventuel serveur existant sur ce port
lsof -ti :$PORT 2>/dev/null | xargs kill 2>/dev/null

echo "==================================================="
echo "  WealthView Dashboard"
echo "  http://localhost:$PORT/$APP_NAME/"
echo "==================================================="
echo ""
echo "  Serveur lancé dans : $APP_DIR"
echo "  Appuyer Ctrl+C pour arrêter"
echo ""

# Ouvrir le navigateur automatiquement (macOS / Linux)
(sleep 1 && {
  if command -v open &>/dev/null; then
    open "http://localhost:$PORT/$APP_NAME/"
  elif command -v xdg-open &>/dev/null; then
    xdg-open "http://localhost:$PORT/$APP_NAME/"
  fi
}) &

# Lancer le serveur HTTP (Python 3, inclus par défaut sur macOS/Linux)
cd "$SERVE_ROOT"
python3 -m http.server $PORT
