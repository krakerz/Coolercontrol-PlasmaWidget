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

```bash
git clone <this-repo-url> ~/Projects/Coolercontrol-PlasmaWidget
cd ~/Projects/Coolercontrol-PlasmaWidget
./install.sh
```

Then add "CoolerControl Monitor" from the widget picker (Add Widgets…).

## Building from source

No build step — this is a plain QML/JS Plasma 6 KPackage. `install.sh`
installs (or upgrades, if already installed) straight from the clone:

```bash
./install.sh
```

To install/upgrade manually instead:

```bash
kpackagetool6 --type Plasma/Applet --install .   # first install
kpackagetool6 --type Plasma/Applet --upgrade .   # subsequent updates
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

---

### Notes

Built and maintained with the help of AI.
