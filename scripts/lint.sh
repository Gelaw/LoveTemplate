#!/usr/bin/env bash
# lint.sh : lint statique (luacheck) de game/, tests/ et .engine/.
#
# Prérequis : luacheck
#   luarocks install luacheck
#   (ou : dnf install lua-luacheck / pacman -S lua-luacheck)
#
# La configuration vit à la racine : .luacheck.lua
# (globals du template, std lua51, exclusions justifiées).
#
# Les WARNINGS ne font pas échouer le script (exit 0) : la base de code
# contient des patterns volontaires (self inutilisé des callbacks LÖVE,
# globals de la façade). Les ERREURS (syntaxe, accès réellement
# indéfinis) font échouer.
set -euo pipefail
cd "$(dirname "$0")/.."

if ! command -v luacheck >/dev/null 2>&1; then
  echo "Erreur : luacheck n'est pas dans le PATH." >&2
  echo "Installez-le : luarocks install luacheck (ou dnf install lua-luacheck)" >&2
  exit 1
fi

# Codes de sortie luacheck : 0 = propre, 1 = warnings, >=2 = erreurs.
# On neutralise les warnings (résumé quand même affiché), pas les erreurs.
set +e
luacheck game tests examples .engine
code=$?
set -e

if [ "$code" -ge 2 ]; then
  echo "Erreur : luacheck a rencontré des ERREURS (code $code)." >&2
  exit "$code"
fi
if [ "$code" -eq 1 ]; then
  echo "Note : warnings présents (non bloquants) — voir le détail ci-dessus."
fi
echo "Lint OK"
