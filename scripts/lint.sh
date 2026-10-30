#!/usr/bin/env bash
# lint.sh : lint statique (luacheck) de game/, tests/ et .engine/.
#
# Prérequis : luacheck
#   luarocks install luacheck
#   (ou : dnf install lua-luacheck / pacman -S lua-luacheck)
#
# La configuration vit à la racine : .luacheck.lua
# (globals du template, std lua51+love, exclusions justifiées).
#
# En pratique : corrigez d'abord les warnings de game/ et tests/
# (votre code). Ceux de .engine/ sont du ressort du template.
set -euo pipefail
cd "$(dirname "$0")/.."

if ! command -v luacheck >/dev/null 2>&1; then
  echo "Erreur : luacheck n'est pas dans le PATH." >&2
  echo "Installez-le : luarocks install luacheck (ou dnf install lua-luacheck)" >&2
  exit 1
fi

exec luacheck game tests .engine
