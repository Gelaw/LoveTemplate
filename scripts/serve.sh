#!/usr/bin/env bash
# serve.sh : sert dist/web sur http://localhost:8000 (uniquement en local).
# Les builds WebAssembly ne fonctionnent pas via file://, un serveur est requis.
set -euo pipefail
cd "$(dirname "$0")/.."

DIR="${1:-dist/web}"
PORT="${2:-8000}"

if [ ! -f "$DIR/index.html" ]; then
  echo "Erreur : $DIR/index.html introuvable. Lancez d'abord scripts/web.sh" >&2
  exit 1
fi

if command -v python3 >/dev/null 2>&1; then
  echo "Serveur local : http://localhost:$PORT  (Ctrl+C pour arreter)"
  exec python3 -m http.server "$PORT" --bind 127.0.0.1 --directory "$DIR"
else
  echo "Erreur : python3 requis pour le serveur local." >&2
  exit 1
fi
