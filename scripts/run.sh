#!/usr/bin/env bash
# run.sh : lance le jeu avec l'executable LÖVE local (dev rapide).
set -euo pipefail
cd "$(dirname "$0")/.."

GAME_DIR="${1:-game}"
if ! command -v love >/dev/null 2>&1; then
  echo "Erreur : la commande 'love' n'est pas dans le PATH." >&2
  echo "Installez LÖVE 11.x : https://love2d.org/" >&2
  exit 1
fi

# Contexte Wayland/NVIDIA : sur certaines stacks (GLX + nvidia-drm), forcer
# XWayland via SDL_VIDEODRIVER=x11 casse le contexte GL (GLXBadCurrentWindow).
# On ne force donc PLUS x11 par défaut : l'input reste fiable grâce au
# suivi événementiel des scancodes (engine.isBindDown, voir core/engine).
# Si votre session a des problèmes graphiques, vous pouvez tester :
#   SDL_VIDEODRIVER=x11 ./scripts/run.sh
exec love "$GAME_DIR"
