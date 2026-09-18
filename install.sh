#!/usr/bin/env bash
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_ID="rie_zel.coolercontrol.monitoring"
ICON_DIR="$HOME/.local/share/icons/hicolor/scalable/apps"

if kpackagetool6 --type Plasma/Applet --list 2>/dev/null | grep -qx "$PLUGIN_ID"; then
    kpackagetool6 --type Plasma/Applet --upgrade "$DIR"
else
    kpackagetool6 --type Plasma/Applet --install "$DIR"
fi

# The widget picker resolves "Icon" as a system icon-theme name, not a
# package-relative path — install our bundled icon into the user's icon
# theme so it isn't shown blank there.
mkdir -p "$ICON_DIR"
cp "$DIR/contents/icons/cc-monitor.svg" "$ICON_DIR/cc-monitor.svg"

echo
echo "Installed. If the widget is already on a panel/desktop, restart plasmashell to pick up the change:"
echo "  kquitapp6 plasmashell && (plasmashell &)"
