#!/usr/bin/env bash
# Installs (or cleanly re-installs) the Pomodoro Timer plasmoid.
#
# kpackagetool6's --upgrade flag is unreliable for this package type, so this
# script always does remove + install instead, which is what actually works.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Pull the plugin ID straight out of metadata.json so this script keeps working
# even after you rename it away from the placeholder.
PLUGIN_ID="$(python3 -c "import json; print(json.load(open('$SCRIPT_DIR/metadata.json'))['KPlugin']['Id'])")"

echo "Removing any previous install of $PLUGIN_ID…"
kpackagetool6 --type Plasma/Applet --remove "$PLUGIN_ID" 2>/dev/null || true
rm -rf "$HOME/.local/share/plasma/plasmoids/$PLUGIN_ID"

echo "Installing $PLUGIN_ID from $SCRIPT_DIR…"
kpackagetool6 --type Plasma/Applet --install "$SCRIPT_DIR"

echo ""
echo "Done. Restart Plasma to load it:"
echo "  plasmashell --replace & disown"
echo "Then add it via right-click on your panel → Add Widgets… → search Pomodoro"
