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

# Sous Wayland, le backend SDL2 remonte parfois SDL_SCANCODE_UNKNOWN pour
# certaines touches des layouts non-QWERTY (AZERTY, BÉPO...), ce qui casse
# les bindings en scancodes (isScancodeDown ne voit qu'une partie du
# clavier). XWayland (x11) utilise une table keycode->scancode fiable.
# On force donc x11 sauf si l'utilisateur impose son propre backend.
if [ -z "${SDL_VIDEODRIVER:-}" ]; then
  export SDL_VIDEODRIVER=x11
fi

exec love "$GAME_DIR"
