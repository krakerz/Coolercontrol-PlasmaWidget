# Changelog

## [Unreleased]

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
