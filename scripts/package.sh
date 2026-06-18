#!/usr/bin/env bash
# Rebuilds pomodoro.plasmoid from the contents/ + metadata.json at the repo root.
# Run this after editing any file, before re-uploading to the KDE Store
# or running scripts/install.sh.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$SCRIPT_DIR"

OUT="$SCRIPT_DIR/pomodoro.plasmoid"
rm -f "$OUT"
zip -r "$OUT" metadata.json contents/ >/dev/null
echo "Built: $OUT"
unzip -l "$OUT"
