#!/usr/bin/env bash
# check.sh : verifie la syntaxe de tous les fichiers .lua (luac -p).
set -euo pipefail
cd "$(dirname "$0")/.."

if ! command -v luac >/dev/null 2>&1; then
  echo "Erreur : 'luac' n'est pas dans le PATH (installez lua ou lua5.x)." >&2
  exit 1
fi

fail=0
for f in $(find game tests .engine -name '*.lua' | sort); do
  if luac -p "$f" 2>/tmp/luac_err.txt; then
    echo "OK   $f"
  else
    echo "FAIL $f"
    cat /tmp/luac_err.txt
    fail=1
  fi
done
exit $fail
