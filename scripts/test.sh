#!/usr/bin/env bash
# test.sh : lance la suite de tests (unitaires, régression, intégration).
#
# Usage :
#   scripts/test.sh              # tout (unit + regression + integration)
#   scripts/test.sh unit         # seulement les tests unitaires
#   scripts/test.sh regression   # non-régression (golden file)
#   scripts/test.sh integration  # intégration (boot + façade)
#
# Le runner est du Lua PUR : aucun binaire LÖVE requis, tout tourne
# avec lua/luajit/lua5.1 (backend graphique mocké, RNG seedé).
set -euo pipefail
cd "$(dirname "$0")/.."

LUA_BIN="${LUA:-}"
if [ -z "$LUA_BIN" ]; then
  for candidate in luajit lua5.1 lua5.3 lua5.4 lua; do
    if command -v "$candidate" >/dev/null 2>&1; then
      LUA_BIN="$candidate"
      break
    fi
  done
fi
if [ -z "$LUA_BIN" ]; then
  echo "Erreur : aucun interpreteur Lua trouve (luajit, lua5.1, lua5.3, lua5.4 ou lua)." >&2
  echo "Installez-en un : apt install lua5.1 / brew install luajit" >&2
  exit 1
fi

MODE="${1:-all}"
echo "Interpreteur : $LUA_BIN"
exec "$LUA_BIN" .engine/src/engine/tests/run.lua "$MODE"
