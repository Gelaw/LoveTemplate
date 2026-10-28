#!/usr/bin/env bash
# clean.sh : supprime les artefacts de build (dist/ et fichiers temporaires).
set -euo pipefail
cd "$(dirname "$0")/.."

rm -rf dist
rm -f /tmp/luac_err.txt
echo "OK nettoyage effectue (dist/ supprime)"
