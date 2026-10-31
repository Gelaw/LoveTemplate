#!/usr/bin/env bash
# check.sh : verifie la syntaxe de tous les fichiers .lua.
# Utilise luac -p si disponible, sinon luajit -bl (meme verification
# syntaxique via le byte-compilateur de LuaJIT).
set -euo pipefail
cd "$(dirname "$0")/.."

CHECK_CMD=""
if command -v luac >/dev/null 2>&1; then
  CHECK_CMD="luac -p"
elif command -v luajit >/dev/null 2>&1; then
  # luajit -b <in> /dev/null : compile sans produire de sortie
  CHECK_CMD="luajit -b"
else
  echo "Erreur : ni 'luac' ni 'luajit' dans le PATH (installez lua, lua5.x ou luajit)." >&2
  exit 1
fi

fail=0
for f in $(find game tests examples .engine -name '*.lua' | sort); do
  if [ "$CHECK_CMD" = "luajit -b" ]; then
    # luajit -b fichier /dev/null : vérifie la syntaxe, jette le bytecode
    if luajit -b "$f" /dev/null 2>/tmp/luac_err.txt; then
      echo "OK   $f"
    else
      echo "FAIL $f"
      cat /tmp/luac_err.txt
      fail=1
    fi
  else
    if luac -p "$f" 2>/tmp/luac_err.txt; then
      echo "OK   $f"
    else
      echo "FAIL $f"
      cat /tmp/luac_err.txt
      fail=1
    fi
  fi
done
exit $fail
