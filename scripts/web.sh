#!/usr/bin/env bash
# web.sh : construit la version web (HTML/JS) du jeu avec love.js.
#
# Prerequis : node.js >= 12 (pour npx). Le paquet npm love.js embarque
# le moteur compile en WebAssembly, aucune compilation locale necessaire.
#
# Usage :
#   scripts/web.sh                   # build dist/web (nom du dossier)
#   scripts/web.sh monjeu            # build dist/web avec titre "monjeu"
#   scripts/web.sh monjeu 134217728  # + memoire personnalisee (octets)
#
# Notes :
#   - Le dossier de sortie (dist/web) est recharge via scripts/serve.sh.
#   - L'option -c (compatibilite) est utilisee par defaut : elle desactive
#     les threads/pthreads, ce qui maximise la compatibilite navigateur
#     (Safari, iOS). Retirez-la si vous n'avez pas besoin de Safari.
set -euo pipefail
cd "$(dirname "$0")/.."

NAME="${1:-$(basename "$(pwd)")}"
MEMORY="${2:-134217728}"  # 128 Mo par defaut, generalement suffisant
OUT_DIR="dist/web"

if ! command -v npx >/dev/null 2>&1; then
  echo "Erreur : node.js/npx requis (https://nodejs.org/)." >&2
  exit 1
fi

LOVE_FILE="dist/${NAME}.love"
# On reconstruit TOUJOURS le .love : sinon un build web repackerait un
# .love obsolète (code source modifié depuis le dernier package) — le
# clean n'est donc jamais nécessaire avant un web.sh.
scripts/package.sh "$NAME"

echo "--> Packaging web avec love.js (titre: ${NAME}, memoire: ${MEMORY} octets)..."
rm -rf "$OUT_DIR"
# Version EPINGEE : `npx love.js` sans version recupererait le dernier
# paquet npm a chaque build (builds non reproductibles entre forks/CI).
# love.js embarque LÖVE 11.4 (voir README) ; 11.4.1 est la derniere
# version publiee du paquet npm au moment de ce template.
npx --yes love.js@11.4.1 -t "$NAME" -m "$MEMORY" -c "$LOVE_FILE" "$OUT_DIR"

# love.js produit index.html + game.js + <nom>.data dans OUT_DIR
echo ""
echo "OK build web -> $OUT_DIR"
echo "Testez avec : scripts/serve.sh"
