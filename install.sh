#!/usr/bin/env bash
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_ID="rie_zel.coolercontrol.monitoring"

if kpackagetool6 --type Plasma/Applet --list 2>/dev/null | grep -qx "$PLUGIN_ID"; then
    kpackagetool6 --type Plasma/Applet --upgrade "$DIR"
else
    kpackagetool6 --type Plasma/Applet --install "$DIR"
fi

# No separate icon-install step needed — the widget self-installs its icon
# into the user's icon theme the first time it actually loads (see main.qml).

echo
echo "Installed. If the widget is already on a panel/desktop, restart plasmashell to pick up the change:"
echo "  kquitapp6 plasmashell && (plasmashell &)"
