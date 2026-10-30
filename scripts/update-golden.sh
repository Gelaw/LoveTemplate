#!/usr/bin/env bash
# update-golden.sh : (re)génère le golden file de non-régression.
# À lancer UNIQUEMENT après un changement de comportement volontaire,
# après relecture du nouveau snapshot (il devient la nouvelle référence).
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
  echo "Erreur : aucun interpreteur Lua trouve." >&2
  exit 1
fi

mkdir -p .engine/src/engine/tests/golden
"$LUA_BIN" .engine/src/engine/tests/run.lua golden
echo ""
echo "Nouveau snapshot :"
cat .engine/src/engine/tests/golden/golden.txt
echo ""
echo "ATTENTION : relisez ce snapshot avant de committer —"
echo "il devient la reference de non-regression."
