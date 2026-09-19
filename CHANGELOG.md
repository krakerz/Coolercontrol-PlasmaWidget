# Changelog

## [Unreleased]

## [2.2.0] — 2026-09-19

### Added
- Configurable icon-to-text spacing on the panel

### Changed
- Sensor/warning icons on the panel now scale with the configured font size instead of a fixed size

## [2.1.0] — 2026-09-18

### Added
- Widget self-installs its icon into the user's icon theme on first load — a plain `.plasmoid` install no longer needs a separate script/step for the icon to show up

## [2.0.1] — 2026-09-18

### Fixed
- Editing any settings field (host/port/username/font size/spacing/refresh interval) could get silently overwritten by a refresh tick while typing
- Number-spinner arrows clipped short placeholder/values in the narrow settings fields

## [2.0.0] — 2026-09-18

### Changed
- Plugin identifier renamed to `rie_zel.coolercontrol.monitoring` — existing installs need to remove and re-add the widget

### Added
- Custom widget icon (CoolerControl's mark with a small KDE Plasma badge)

## [1.1.1] — 2026-09-18

### Fixed
- Renaming a sensor label could get silently overwritten by a refresh tick while typing

## [1.1.0] — 2026-09-18

### Added
- Configurable widget text: font size, sensor-label toggle, and label/value spacing
- Per-sensor custom label renaming
- Configurable refresh interval

### Fixed
- Full representation popup sometimes rendered solid black on reopen
- Pin/hide toggle icons were off-center in their buttons
