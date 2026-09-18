# CoolerControl Monitor

A KDE Plasma 6 widget that shows live CPU/GPU/fan/PSU sensor readings from a
local [CoolerControl](https://gitlab.com/coolercontrol/coolercontrol) daemon.

## Description

CoolerControl Monitor talks directly to a running `coolercontrold` instance
over its REST API and surfaces the sensors you care about on your panel or
desktop, without needing the full CoolerControl GUI open. It's unaffiliated
with the CoolerControl project — just a thin client against its existing API.

## Features

- Pin any sensor to the compact panel/desktop view
- Optional sensor labels next to values, with configurable font size and
  label/value spacing
- Rename any sensor's display label (e.g. "Total Power" → "TP")
- Horizontal or vertical layout, matching how you place the widget
- Hide sensors you don't need from the full sensor list
- Configurable refresh interval
- Automatic login/session handling against the CoolerControl daemon

## Installation

Requires a running CoolerControl daemon (`coolercontrold`) reachable over
HTTP.

Download the `.plasmoid` file from the [Releases](../../releases) page, then
either:

- Right-click your desktop or panel → **Add Widgets…** → **Get New
  Widgets…** → **Install Widget From Local File…**, and pick the downloaded
  `.plasmoid`, or
- Install it from a terminal:

  ```bash
  kpackagetool6 --type Plasma/Applet --install coolercontrol-monitor-<version>.plasmoid
  ```

Then add "CoolerControl Monitor" from the widget picker (Add Widgets…).

## Building from source

No build step for the widget itself — it's a plain QML/JS Plasma 6 KPackage.
Working from a clone instead of a downloaded `.plasmoid`:

```bash
git clone <this-repo-url> ~/Projects/Coolercontrol-PlasmaWidget
cd ~/Projects/Coolercontrol-PlasmaWidget
./install.sh
```

`install.sh` installs (or upgrades, if already installed) straight from the
clone. To build your own `.plasmoid` archive instead (what CI attaches to
each release):

```bash
./package.sh   # writes coolercontrol-monitor-<version>.plasmoid
```

## Usage

1. Add the widget to a panel or your desktop.
2. Open it and set your CoolerControl host/port and credentials in the
   settings (gear icon).
3. Pin the sensors you want visible on the panel with the pin icon next to
   each sensor.
4. Optionally enable sensor labels, adjust font size/spacing, and rename any
   sensor from the same list.

## FAQ

**The widget shows "Set a CoolerControl password in the widget settings"?**
CoolerControl requires a password even for the default `CCAdmin` account —
enter whatever you configured in CoolerControl itself.

**Nothing shows up on the panel?**
The compact view only shows pinned sensors — pin at least one from the full
sensor list first.

**The widget's icon shows up blank in the widget picker?**
The picker resolves icons by system icon-theme name — installing the
`.plasmoid` itself never registers anything into your icon theme. The
widget self-installs its icon the first time it actually loads (once
added to a panel/desktop), so this fixes itself the next time you open the
picker after that. It stays blank only for that very first look, before
the widget has ever been added anywhere.

## Trademarks & attribution

- The widget icon is CoolerControl's own mark
  (`org.coolercontrol.CoolerControl.svg`, © 2021 Guy Boldon and contributors,
  GPL-3.0-or-later) with a small KDE Plasma badge overlaid, adapted from
  Breeze's `start-here-kde-plasma.svg`.
- "CoolerControl" and its logo belong to the [CoolerControl
  project](https://gitlab.com/coolercontrol/coolercontrol). This widget is
  an unofficial, unaffiliated client and claims no ownership over them.
- "KDE", "Plasma", and the Plasma logo are trademarks of [KDE
  e.V.](https://kde.org). This widget is not endorsed by or affiliated with
  KDE e.V.

---

### Notes

Built and maintained with the help of AI.
