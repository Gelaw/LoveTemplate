#!/usr/bin/env bash
# package.sh : construit dist/<nom>.love (archive zip du dossier src).
set -euo pipefail
cd "$(dirname "$0")/.."

NAME="${1:-$(basename "$(pwd)")}"
OUT="dist/${NAME}.love"
mkdir -p dist
rm -f "$OUT"

if command -v zip >/dev/null 2>&1; then
  (cd src && zip -r "../$OUT" . -x '*.DS_Store' -x '__pycache__/*' >/dev/null)
else
  echo "Erreur : 'zip' requis." >&2
  exit 1
fi
echo "OK $OUT"
