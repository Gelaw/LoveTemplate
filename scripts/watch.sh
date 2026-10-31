#!/usr/bin/env bash
# watch.sh : relance le jeu a chaque modification d'un .lua (hot-reload
# "pauvre" mais efficace et sans dependance : scrutation des mtimes).
#
# Usage :
#   scripts/watch.sh              # surveille game/ et relance `love game`
#   scripts/watch.sh examples/snake   # surveille un autre dossier de jeu
#
# Necessite `love` dans le PATH. Ctrl+C pour arreter (tue le jeu en cours).
set -euo pipefail
cd "$(dirname "$0")/.."

GAME_DIR="${1:-game}"

if ! command -v love >/dev/null 2>&1; then
  echo "Erreur : la commande 'love' n'est pas dans le PATH." >&2
  exit 1
fi

SENTINEL="$(mktemp)"
trap 'rm -f "$SENTINEL"; [ -n "${LOVE_PID:-}" ] && kill "$LOVE_PID" 2>/dev/null; exit 0' INT TERM

echo "Watch : surveillance de $GAME_DIR/*.lua — Ctrl+C pour arreter."
love "$GAME_DIR" &
LOVE_PID=$!

while true; do
  sleep 0.5
  # un fichier .lua plus recent que la sentinelle -> on relance
  if find "$GAME_DIR" .engine/src -name '*.lua' -newer "$SENTINEL" -print -quit 2>/dev/null | grep -q .; then
    echo "--> changement detecte, relance du jeu..."
    kill "$LOVE_PID" 2>/dev/null || true
    wait "$LOVE_PID" 2>/dev/null || true
    touch "$SENTINEL"
    love "$GAME_DIR" &
    LOVE_PID=$!
  fi
done
