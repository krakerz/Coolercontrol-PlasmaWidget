import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasmoid
import org.kde.plasma.components as PlasmaComponents3

Item {
    id: compact

    readonly property bool vertical: Plasmoid.configuration.panelOrientation === "vertical"
    readonly property bool showLabels: Plasmoid.configuration.showSensorLabels
    // Table-style row layout (icon+label left, value right) only makes sense
    // once sensors are stacked in a column — a horizontal chip row just gets
    // the label text inline instead.
    readonly property bool useLabelTable: vertical && showLabels
    readonly property int fontPixelSize: Plasmoid.configuration.fontPixelSize > 0 ? Plasmoid.configuration.fontPixelSize : Kirigami.Theme.defaultFont.pixelSize
    // Extra gap between a sensor's label and its value, on top of the row's
    // own base spacing — only meaningful once a label is actually shown.
    readonly property int valueSpacing: showLabels ? Plasmoid.configuration.sensorSpacing : 0
    // Icons scale with the configured font size instead of a fixed theme
    // size, so they stay proportionate at any font-size setting.
    readonly property int iconSize: Math.round(compact.fontPixelSize * 1.15)
    // Extra gap between the icon and whatever follows it (label or value) —
    // the row's own base spacing alone gets cramped once icons scale up.
    readonly property int iconSpacing: Plasmoid.configuration.iconSpacing

    readonly property var deviceColors: ({
            "CPU": "#ff6b6b",
            "GPU": "#ffa94d",
            "Liquidctl": "#4dabf7",
            "Hwmon": "#63e6be",
            "CustomSensors": "#da77f2"
        })

    function colorForDevice(deviceType) {
        return compact.deviceColors[deviceType] || "#9a9a9a";
    }

    function iconSvg(unit, color) {
        switch (unit) {
        case "°C":
            return '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="' + color + '"><rect x="10" y="3" width="4" height="12" rx="2"/><circle cx="12" cy="18" r="4"/></svg>';
        case "W":
            return '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="' + color + '"><path d="M13 2 3 14h7l-1 8 10-12h-7l1-8z"/></svg>';
        case "RPM":
        case "%":
            return '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="' + color + '" stroke-width="2" stroke-linecap="round"><line x1="12" y1="2" x2="12" y2="7"/><line x1="12" y1="17" x2="12" y2="22"/><line x1="2" y1="12" x2="7" y2="12"/><line x1="17" y1="12" x2="22" y2="12"/><line x1="4.9" y1="4.9" x2="8.5" y2="8.5"/><line x1="15.5" y1="15.5" x2="19.1" y2="19.1"/><line x1="19.1" y1="4.9" x2="15.5" y2="8.5"/><line x1="8.5" y1="15.5" x2="4.9" y2="19.1"/></svg>';
        case "MHz":
            return '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="' + color + '" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="2,12 7,12 9,5 13,19 15,12 22,12"/></svg>';
        default:
            return '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="' + color + '"><circle cx="12" cy="12" r="6"/></svg>';
        }
    }

    function iconUrl(sensor) {
        var color = colorForDevice(sensor.deviceType);
        return "data:image/svg+xml;utf8," + encodeURIComponent(iconSvg(sensor.unit, color));
    }

    Layout.minimumWidth: vertical
        ? (useLabelTable ? columnLayout.implicitWidth : compact.iconSize) + Kirigami.Units.smallSpacing * 2
        : flowRow.implicitWidth + Kirigami.Units.smallSpacing * 2
    Layout.preferredWidth: Layout.minimumWidth
    Layout.minimumHeight: vertical
        ? (useLabelTable ? columnLayout.implicitHeight : flowRow.implicitHeight) + Kirigami.Units.smallSpacing * 2
        : compact.iconSize + Kirigami.Units.smallSpacing * 2
    Layout.preferredHeight: Layout.minimumHeight

    // Horizontal chip row, or vertical icon(+label)-stack without the
    // right-aligned value column.
    Flow {
        id: flowRow
        visible: !compact.useLabelTable
        anchors.centerIn: parent
        flow: compact.vertical ? Flow.TopToBottom : Flow.LeftToRight
        spacing: Kirigami.Units.smallSpacing

        Kirigami.Icon {
            visible: widgetRoot.hasError
            source: "dialog-warning"
            width: compact.iconSize
            height: compact.iconSize
        }

        Repeater {
            model: flowRow.visible ? widgetRoot.pinnedSensors : []
            delegate: RowLayout {
                spacing: Kirigami.Units.smallSpacing / 2
                Image {
                    source: compact.iconUrl(modelData)
                    Layout.preferredWidth: compact.iconSize
                    Layout.preferredHeight: compact.iconSize
                    Layout.rightMargin: compact.iconSpacing
                    sourceSize.width: width
                    sourceSize.height: height
                }
                PlasmaComponents3.Label {
                    visible: compact.showLabels
                    Layout.rightMargin: compact.valueSpacing
                    text: modelData.label
                    font.pixelSize: compact.fontPixelSize
                }
                PlasmaComponents3.Label {
                    text: modelData.display
                    font.pixelSize: compact.fontPixelSize
                }
            }
        }

        PlasmaComponents3.Label {
            visible: widgetRoot.pinnedSensors.length === 0 && !widgetRoot.hasError
            text: widgetRoot.busy ? i18n("Loading…") : i18n("No pinned sensors")
            font.pixelSize: compact.fontPixelSize
        }
    }

    // Vertical table: icon + label left-aligned, value right-aligned — every
    // row stretches to the same width so the value column lines up.
    ColumnLayout {
        id: columnLayout
        visible: compact.useLabelTable
        anchors.centerIn: parent
        spacing: Kirigami.Units.smallSpacing / 2

        RowLayout {
            visible: widgetRoot.hasError
            Layout.fillWidth: true
            Kirigami.Icon {
                source: "dialog-warning"
                width: compact.iconSize
                height: compact.iconSize
            }
        }

        Repeater {
            model: columnLayout.visible ? widgetRoot.pinnedSensors : []
            delegate: RowLayout {
                Layout.fillWidth: true
                spacing: Kirigami.Units.smallSpacing / 2
                Image {
                    source: compact.iconUrl(modelData)
                    Layout.preferredWidth: compact.iconSize
                    Layout.preferredHeight: compact.iconSize
                    Layout.rightMargin: compact.iconSpacing
                    sourceSize.width: width
                    sourceSize.height: height
                }
                PlasmaComponents3.Label {
                    Layout.fillWidth: true
                    Layout.rightMargin: compact.valueSpacing
                    text: modelData.label
                    font.pixelSize: compact.fontPixelSize
                    elide: Text.ElideRight
                }
                PlasmaComponents3.Label {
                    text: modelData.display
                    font.pixelSize: compact.fontPixelSize
                    horizontalAlignment: Text.AlignRight
                }
            }
        }

        PlasmaComponents3.Label {
            visible: widgetRoot.pinnedSensors.length === 0 && !widgetRoot.hasError
            text: widgetRoot.busy ? i18n("Loading…") : i18n("No pinned sensors")
            font.pixelSize: compact.fontPixelSize
        }
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: widgetRoot.expanded = !widgetRoot.expanded
    }
}
