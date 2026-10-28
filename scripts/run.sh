#!/usr/bin/env bash
# run.sh : lance le jeu avec l'executable LÖVE local (dev rapide).
set -euo pipefail
cd "$(dirname "$0")/.."

GAME_DIR="${1:-src}"
if ! command -v love >/dev/null 2>&1; then
  echo "Erreur : la commande 'love' n'est pas dans le PATH." >&2
  echo "Installez LÖVE 11.x : https://love2d.org/" >&2
  exit 1
fi
exec love "$GAME_DIR"
