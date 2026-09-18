import QtQuick
import QtQuick.Layouts
import QtWebEngine
import org.kde.plasma.plasmoid

Item {
    id: full

    Layout.minimumWidth: 320
    Layout.minimumHeight: 400
    Layout.preferredWidth: 420
    Layout.preferredHeight: 560

    function pushState() {
        if (!webViewLoader.item) {
            return;
        }
        // Send every sensor, unfiltered — hidden ones are filtered for
        // DISPLAY inside the page (which also lets the page offer a "show
        // hidden" toggle), not dropped before they ever arrive.
        var payload = {
            sensors: widgetRoot.displaySensors,
            pinnedKeys: widgetRoot.keyList(Plasmoid.configuration.pinnedKeys),
            hiddenKeys: widgetRoot.keyList(Plasmoid.configuration.hiddenKeys),
            hasError: widgetRoot.hasError,
            errorMessage: widgetRoot.errorMessage,
            apiHost: Plasmoid.configuration.apiHost,
            apiPort: Plasmoid.configuration.apiPort,
            username: Plasmoid.configuration.username,
            hasPassword: !!Plasmoid.configuration.password,
            panelOrientation: Plasmoid.configuration.panelOrientation,
            showSensorLabels: Plasmoid.configuration.showSensorLabels,
            fontPixelSize: Plasmoid.configuration.fontPixelSize,
            sensorSpacing: Plasmoid.configuration.sensorSpacing,
            refreshIntervalMs: Plasmoid.configuration.refreshIntervalMs
        };
        webViewLoader.item.runJavaScript("window.ccUpdate && window.ccUpdate(" + JSON.stringify(payload) + ")");
    }

    function handleMessage(msg) {
        if (msg.cmd === "pin") {
            widgetRoot.setPinned(msg.key, msg.value);
        } else if (msg.cmd === "hide") {
            widgetRoot.setHidden(msg.key, msg.value);
        } else if (msg.cmd === "setOrientation") {
            widgetRoot.setOrientation(msg.value);
        } else if (msg.cmd === "setShowLabels") {
            widgetRoot.setShowSensorLabels(msg.value);
        } else if (msg.cmd === "setFontSize") {
            widgetRoot.setFontPixelSize(msg.value);
        } else if (msg.cmd === "setSensorSpacing") {
            widgetRoot.setSensorSpacing(msg.value);
        } else if (msg.cmd === "setRefreshInterval") {
            widgetRoot.setRefreshIntervalMs(msg.value);
        } else if (msg.cmd === "renameLabel") {
            widgetRoot.setSensorLabel(msg.key, msg.value);
        } else if (msg.cmd === "saveCredentials") {
            widgetRoot.saveCredentials(msg.host, msg.port, msg.username, msg.password);
        } else if (msg.cmd === "refresh") {
            widgetRoot.refresh();
        } else if (msg.cmd === "ready") {
            // page just loaded, fall through to pushState below
        }
        full.pushState();
    }

    Loader {
        id: webViewLoader
        anchors.fill: parent
        // Recreated (not just shown/hidden) on every popup open — reusing a
        // WebEngineView across hide/show renders solid black, since its
        // GPU-backed surface goes stale while the popup is hidden.
        active: Plasmoid.expanded
        sourceComponent: WebEngineView {
            anchors.fill: parent
            url: Qt.resolvedUrl("dashboard.html")
            backgroundColor: "#1d1d1d"

            onTitleChanged: {
                if (title.indexOf("cc:") !== 0) {
                    return;
                }
                var raw = title.substring(3);
                try {
                    var msg = JSON.parse(raw);
                    full.handleMessage(msg);
                } catch (e) {
                    // ignore malformed payloads
                }
            }

            Component.onCompleted: Qt.callLater(function () {
                // A freshly (re)created WebEngineView sometimes leaves its
                // first frame un-presented until an input/focus event nudges
                // the compositor — force one instead of waiting on the user
                // to hover over it.
                forceActiveFocus();
                grabToImage(function () {});
            })
        }
    }

    Connections {
        target: widgetRoot
        function onSensorsChanged() {
            full.pushState();
        }
        function onHasErrorChanged() {
            full.pushState();
        }
    }
}
