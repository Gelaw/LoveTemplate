#!/usr/bin/env bash
# serve.sh : sert dist/web en HTTP local — obligatoire pour tester un
# build WebAssembly (ne charge pas en file://).
#
# Usage :
#   scripts/serve.sh              # localhost uniquement (127.0.0.1)
#   scripts/serve.sh lan          # accessible sur le réseau local (0.0.0.0)
#   scripts/serve.sh [lan] <dir> <port>
#
# Le mode par défaut boucle sur 127.0.0.1 : rien n'est exposé au LAN.
# Le mode "lan" sert sur 0.0.0.0 (test téléphone/tablette) — à couper
# après usage.
set -euo pipefail
cd "$(dirname "$0")/.."

BIND="127.0.0.1"
ARGS=()
for a in "$@"; do
  if [ "$a" = "lan" ]; then
    BIND="0.0.0.0"
  else
    ARGS+=("$a")
  fi
done
DIR="${ARGS[0]:-dist/web}"
PORT="${ARGS[1]:-8000}"

if [ ! -f "$DIR/index.html" ]; then
  echo "Erreur : $DIR/index.html introuvable. Lancez d'abord scripts/web.sh" >&2
  exit 1
fi

if ! command -v python3 >/dev/null 2>&1; then
  echo "Erreur : python3 requis pour le serveur local." >&2
  exit 1
fi

if [ "$BIND" = "0.0.0.0" ]; then
  echo "Serveur LAN : http://$(hostname -I 2>/dev/null | awk '{print $1}'):$PORT  (0.0.0.0 — a couper apres usage)"
else
  echo "Serveur local : http://localhost:$PORT  (Ctrl+C pour arreter)"
fi
exec python3 -m http.server "$PORT" --bind "$BIND" --directory "$DIR"
