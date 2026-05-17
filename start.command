#!/bin/bash
# WealthView Dashboard - start a local HTTP server and open the browser
PORT=8080
cd "$(dirname "$0")"

echo "==================================================="
echo "  WealthView Dashboard"
echo "  http://localhost:$PORT/"
echo "==================================================="
echo "  Press Ctrl+C to stop."
echo ""

(sleep 1 && {
  if command -v open >/dev/null 2>&1; then
    open "http://localhost:$PORT/"
  elif command -v xdg-open >/dev/null 2>&1; then
    xdg-open "http://localhost:$PORT/"
  fi
}) &

python3 -m http.server $PORT
