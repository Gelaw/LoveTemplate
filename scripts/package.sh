#!/usr/bin/env bash
# package.sh : construit dist/<nom>.love.
#
# Archive composée :
#   - le CONTENU de game/ est à la racine du .love (LÖVE y cherche
#     main.lua / conf.lua)
#   - .engine/src/engine/ est copié TEL QUEL comme sous-dossier
#     "engine/" : require("engine.*") trouve ainsi le même namespace
#     dans l'archive qu'en dev
#   - les tests du template (engine/tests) sont exclus de l'archive ;
#     vos assets de game/ sont inclus avec le contenu de game/
set -euo pipefail
cd "$(dirname "$0")/.."

NAME="${1:-$(basename "$(pwd)")}"
mkdir -p dist
# Chemin ABSOLU : les sous-shells changent de dossier (game/,
# .engine/src), un chemin relatif y serait résolu au mauvais endroit.
OUT="$(pwd)/dist/${NAME}.love"
rm -f "$OUT"

if ! command -v zip >/dev/null 2>&1; then
  echo "Erreur : 'zip' requis." >&2
  exit 1
fi

# stdout de zip est bruyant (liste chaque fichier) : on le silencie,
# mais PAS stderr — une erreur de packaging doit rester visible.
if ! (cd game && zip -r "$OUT" . -x '*.DS_Store' >/dev/null); then
  echo "Erreur : zip a échoué sur game/" >&2
  exit 1
fi
if ! (cd .engine/src && zip -r "$OUT" engine -x 'engine/tests/*' -x '*.DS_Store' >/dev/null); then
  echo "Erreur : zip a échoué sur .engine/src/engine/" >&2
  exit 1
fi
echo "OK $OUT"
