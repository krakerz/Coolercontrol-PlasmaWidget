#!/usr/bin/env bash
set -euo pipefail

kpackagetool6 --type Plasma/Applet --remove rie_zel.coolercontrol.monitoring
rm -f "$HOME/.local/share/icons/hicolor/scalable/apps/cc-monitor.svg"
