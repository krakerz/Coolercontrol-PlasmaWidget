import QtQuick
import org.kde.plasma.plasmoid
import org.kde.plasma.plasma5support as Plasma5Support
import "CoolerControlClient.js" as CCClient

PlasmoidItem {
    id: widgetRoot

    readonly property string baseUrl: "http://" + Plasmoid.configuration.apiHost + ":" + Plasmoid.configuration.apiPort

    property var sensors: []
    property var deviceInfoByUid: ({})
    property bool loggedIn: false
    property bool busy: false
    property bool hasError: false
    property string errorMessage: ""

    function keyList(str) {
        return (str || "").split(',').map(function (s) {
            return s.trim();
        }).filter(function (s) {
            return s.length > 0;
        });
    }

    readonly property var labelOverrides: {
        try {
            return JSON.parse(Plasmoid.configuration.sensorLabelOverrides || "{}");
        } catch (e) {
            return {};
        }
    }

    // sensors with any custom label applied — original name kept as
    // `originalLabel` so the rename UI can show/reset to it.
    readonly property var displaySensors: {
        var overrides = widgetRoot.labelOverrides;
        return widgetRoot.sensors.map(function (s) {
            var copy = Object.assign({}, s);
            copy.originalLabel = s.label;
            if (overrides[s.key]) {
                copy.label = overrides[s.key];
            }
            return copy;
        });
    }

    readonly property var pinnedSensors: {
        var pins = keyList(Plasmoid.configuration.pinnedKeys);
        var out = [];
        for (var i = 0; i < pins.length; i++) {
            for (var j = 0; j < displaySensors.length; j++) {
                if (displaySensors[j].key === pins[i]) {
                    out.push(displaySensors[j]);
                    break;
                }
            }
        }
        return out;
    }

    function setPinned(key, value) {
        var pins = keyList(Plasmoid.configuration.pinnedKeys);
        var idx = pins.indexOf(key);
        if (value && idx === -1) {
            pins.push(key);
        } else if (!value && idx !== -1) {
            pins.splice(idx, 1);
        }
        Plasmoid.configuration.pinnedKeys = pins.join(',');
    }

    function setHidden(key, value) {
        var hidden = keyList(Plasmoid.configuration.hiddenKeys);
        var idx = hidden.indexOf(key);
        if (value && idx === -1) {
            hidden.push(key);
        } else if (!value && idx !== -1) {
            hidden.splice(idx, 1);
        }
        Plasmoid.configuration.hiddenKeys = hidden.join(',');
    }

    function setOrientation(value) {
        Plasmoid.configuration.panelOrientation = value === "vertical" ? "vertical" : "horizontal";
    }

    function setShowSensorLabels(value) {
        Plasmoid.configuration.showSensorLabels = !!value;
    }

    function setFontPixelSize(value) {
        var size = parseInt(value, 10);
        Plasmoid.configuration.fontPixelSize = (isNaN(size) || size <= 0) ? 0 : size;
    }

    function setSensorSpacing(value) {
        var size = parseInt(value, 10);
        Plasmoid.configuration.sensorSpacing = (isNaN(size) || size < 0) ? 0 : Math.min(size, 64);
    }

    function setIconSpacing(value) {
        var size = parseInt(value, 10);
        Plasmoid.configuration.iconSpacing = (isNaN(size) || size < 0) ? 0 : Math.min(size, 64);
    }

    function setRefreshIntervalMs(value) {
        var ms = parseInt(value, 10);
        if (isNaN(ms)) {
            return;
        }
        Plasmoid.configuration.refreshIntervalMs = Math.max(1000, Math.min(ms, 300000));
    }

    function setSensorLabel(key, label) {
        var overrides = Object.assign({}, widgetRoot.labelOverrides);
        var trimmed = (label || "").trim();
        if (trimmed) {
            overrides[key] = trimmed;
        } else {
            delete overrides[key];
        }
        Plasmoid.configuration.sensorLabelOverrides = JSON.stringify(overrides);
    }

    function saveCredentials(host, port, username, password) {
        if (host) {
            Plasmoid.configuration.apiHost = host;
        }
        var portNum = parseInt(port, 10);
        if (!isNaN(portNum)) {
            Plasmoid.configuration.apiPort = portNum;
        }
        if (username) {
            Plasmoid.configuration.username = username;
        }
        if (password) {
            Plasmoid.configuration.password = password;
        }
        widgetRoot.loggedIn = false;
        widgetRoot.deviceInfoByUid = ({});
        widgetRoot.refresh();
    }

    function doLogin(callback) {
        if (!Plasmoid.configuration.password) {
            widgetRoot.hasError = true;
            widgetRoot.errorMessage = i18n("Set a CoolerControl password in the widget settings");
            callback(false);
            return;
        }
        CCClient.login(widgetRoot.baseUrl, Plasmoid.configuration.username, Plasmoid.configuration.password, function (ok, status) {
            widgetRoot.loggedIn = ok;
            if (!ok) {
                widgetRoot.hasError = true;
                widgetRoot.errorMessage = i18n("CoolerControl login failed (HTTP %1)", status);
            }
            callback(ok);
        });
    }

    function ensureDevices(callback) {
        if (Object.keys(widgetRoot.deviceInfoByUid).length > 0) {
            callback(true);
            return;
        }
        CCClient.fetchDevices(widgetRoot.baseUrl, function (ok, json) {
            if (ok) {
                var map = {};
                json.devices.forEach(function (d) {
                    map[d.uid] = d;
                });
                widgetRoot.deviceInfoByUid = map;
            }
            callback(ok);
        });
    }

    function refresh() {
        if (widgetRoot.busy) {
            return;
        }
        widgetRoot.busy = true;

        function finish() {
            widgetRoot.busy = false;
        }

        function pullStatus() {
            CCClient.fetchStatus(widgetRoot.baseUrl, function (ok, json, status) {
                if (ok) {
                    widgetRoot.hasError = false;
                    widgetRoot.errorMessage = "";
                    widgetRoot.sensors = CCClient.buildSensors(widgetRoot.deviceInfoByUid, json);
                    finish();
                } else if (status === 401) {
                    // Session expired (or plasmashell/coolercontrold restarted) — relogin once and retry.
                    widgetRoot.loggedIn = false;
                    widgetRoot.doLogin(function (ok2) {
                        if (ok2) {
                            pullStatus();
                        } else {
                            finish();
                        }
                    });
                } else {
                    widgetRoot.hasError = true;
                    widgetRoot.errorMessage = i18n("Status fetch failed (HTTP %1)", status);
                    finish();
                }
            });
        }

        if (!widgetRoot.loggedIn) {
            widgetRoot.doLogin(function (ok) {
                if (!ok) {
                    finish();
                    return;
                }
                widgetRoot.ensureDevices(function () {
                    pullStatus();
                });
            });
        } else {
            widgetRoot.ensureDevices(function () {
                pullStatus();
            });
        }
    }

    Timer {
        interval: Plasmoid.configuration.refreshIntervalMs
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: widgetRoot.refresh()
    }

    // The widget picker resolves the "Icon" metadata field as a plain
    // icon-theme name — installing the .plasmoid itself never registers
    // anything into the user's icon theme, so on a fresh system the icon
    // shows up blank until this runs at least once. Self-installs it into
    // the user's icon theme the first time this widget actually loads, so
    // a plain .plasmoid install needs no separate script/step.
    Plasma5Support.DataSource {
        id: iconInstaller
        engine: "executable"
        connectedSources: []
        onNewData: disconnectSource(sourceName)

        Component.onCompleted: {
            var iconPath = Qt.resolvedUrl("../icons/cc-monitor.svg").toString().replace("file://", "");
            connectSource("mkdir -p ~/.local/share/icons/hicolor/scalable/apps && cp '" + iconPath + "' ~/.local/share/icons/hicolor/scalable/apps/cc-monitor.svg");
        }
    }

    preferredRepresentation: compactRepresentation
    compactRepresentation: CompactRepresentation {}
    fullRepresentation: FullRepresentation {}

    toolTipMainText: i18n("CoolerControl")
    toolTipSubText: widgetRoot.hasError ? widgetRoot.errorMessage : widgetRoot.pinnedSensors.map(function (s) {
        return s.label + ": " + s.display;
    }).join("\n")
}
