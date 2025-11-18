import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.modules.common
import qs.modules.common.utils
import qs.modules.common.widgets
import qs.modules.icons
import qs.services

Item {
    id: root

    property real scale: Config.data.network.scale
    property real history: Config.data.network.graph.history
    property var points: []  // Graph points: [{x: time, up: bytes/s, down: bytes/s}]
    readonly property var unitHierarchy: FileUtils.getUnitHierarchy(Config.data.network.rates.baseUnit)

    implicitWidth: (graph.visible ? graph.width : 0)
        + (iconLoader.visible ? iconLoader.width : 0)
        + (rates.visible ? rates.width : 0) + 4
    implicitHeight: Config.data.bar.size - Config.data.bar.size * 0.2

    Component.onCompleted: points.push({x: Date.now(), up: 0, down: 0});

    Timer {
        interval: Config.data.network.rateUpdateInterval
        running: true
        repeat: true
        onTriggered: {
            const x = Date.now(), up = Network.rateUp, down = Network.rateDown;
            points.push({x, up, down});
            const cutoff = x - history * 1000;
            while (points.length && points[0].x < cutoff) points.shift();
            graph.requestPaint();
        }
    }

    Loader {
        id: iconLoader
        visible: Config.data.network.icon.enabled
        width: sourceComponent.width
        height: sourceComponent.height
        anchors.verticalCenter: parent.verticalCenter
        sourceComponent: Network.networkType === Types.Network.Wireless ?
                         wirelessIcon :
                         (Network.networkType === Types.Network.Wired ? wiredIcon : virtualIcon)
    }

    Component {
        id: wiredIcon
        NetworkWiredIcon {
            color: Config.data.network.icon.color
            scale: Config.data.network.icon.scale * root.height
            anchors.verticalCenter: parent.verticalCenter
        }
    }
    Component {
        id: wirelessIcon
        NetworkWirelessIcon {
            color: Config.data.network.icon.color
            scale: Config.data.network.icon.scale * root.height
            anchors.verticalCenter: parent.verticalCenter
            bars: {
                const thresholds = [-60, -70, -80, -90];
                let numBars = 3;
                for (let i=0; i < thresholds.length; ++i) {
                    if (Network.signalStrength > thresholds[i]) break;
                    numBars--;
                }
                return Math.max(numBars, 0);
            }
        }
    }
    Component {
        id: virtualIcon
        NetworkVirtualIcon {
            color: Config.data.network.icon.color
            scale: Config.data.network.icon.scale * root.height
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    Canvas {
        id: graph
        visible: Config.data.network.graph.enabled
        anchors {
            top: parent.top
            bottom: parent.bottom
            left: iconLoader.right
            leftMargin: iconLoader.visible ? 2 : 0
        }
        implicitWidth: visible ? 100 * root.scale : 0

        onPaint: {
            const ctx = getContext("2d");
            ctx.clearRect(0, 0, width, height);
            if (points.length < 2) return;

            const range = history * 1000, currentTime = Date.now(), minTime = currentTime - range;
            const visiblePoints = points.filter(p => p.x >= minTime);
            const margin = 2, marginHeight = height - 2 * margin;

            const drawLine = function(prop, color) {
                ctx.strokeStyle = color;
                ctx.beginPath();
                for (let i = 0; i < visiblePoints.length; ++i) {
                    const px = ((visiblePoints[i].x - minTime) / range) * width;
                    const py = margin + (1 - visiblePoints[i][prop] / maxRate) * marginHeight;
                    if (i === 0) ctx.moveTo(px, py);
                    ctx.lineTo(px, py);
                }
                ctx.stroke();
            }

            ctx.lineWidth = 2;
            drawLine('up', Config.data.network.colors.tx);
            drawLine('down', Config.data.network.colors.rx)
        }
        property real maxRate: 1  // Computed: max of all up/down points, updated on paint
        onPainted: { maxRate = Math.max(...points.map(p => Math.max(p.up, p.down)), 1); }
    }


    // Return the rate value using the most appropriate unit within the given
    // hierarchy, starting with the given base unit.
    // This ensures that the rate component never displays more than 5 digits,
    // so that it can have a predictable max width.
    function getDisplayRate(rateBytes, fromUnit, baseUnit, hierarchy) {
        const startIndex = Math.max(0, hierarchy.indexOf(baseUnit));

        for (let i = startIndex; i < hierarchy.length; i++) {
            const unit = hierarchy[i];
            const rate = FileUtils.convertSizeUnit(rateBytes, fromUnit, unit);

            // Use this unit if rate fits OR it's the last available unit
            if (rate < 1000 || i === hierarchy.length - 1) {
                return {unit, rate};
            }
        }

        // Fallback to largest unit. Shouldn't happen...
        const lastUnit = hierarchy[hierarchy.length - 1];
        return {
            unit: lastUnit,
            rate: FileUtils.convertSizeUnit(rateBytes, fromUnit, lastUnit)
        };
    }

    ColumnLayout {
        id: rates
        visible: Config.data.network.rates.enabled
        spacing: -4
        anchors {
            left: graph.right
            leftMargin: 4
            verticalCenter: parent.verticalCenter
        }

        // Calculate fixed width based on maximum possible text
        TextMetrics {
            id: rateTextMetrics
            // The "M" in "MiB", "MB", etc. is usually the widest font glyph.
            text: "999.99 " + root.unitHierarchy[1] + "/s"
            font.family: Config.data.theme.font.family
            font.pixelSize: Config.data.theme.font.size * 0.9
        }

        RowLayout {
            spacing: 2
            ArrowIcon {
                id: txArrowIcon
                scale: root.height / 2
                angle: 0
                color: Config.data.network.colors.tx
            }
            Text {
                text: {
                    const display = getDisplayRate(Network.rateUp, 'B', Config.data.network.rates.baseUnit, root.unitHierarchy);
                    return `${display.rate.toFixed(2)} ${display.unit}/s`;
                }
                font.family: Config.data.theme.font.family
                font.pixelSize: Config.data.theme.font.size * 0.9
                color: Config.data.network.colors.tx
                Layout.preferredWidth: rateTextMetrics.width
                horizontalAlignment: Text.AlignRight
            }
        }

        RowLayout {
            spacing: 2
            ArrowIcon {
                id: rxArrowIcon
                scale: root.height / 2
                angle: 180
                color: Config.data.network.colors.rx
            }
            Text {
                text: {
                    const display = getDisplayRate(Network.rateDown, 'B', Config.data.network.rates.baseUnit, root.unitHierarchy);
                    return `${display.rate.toFixed(2)} ${display.unit}/s`;
                }
                font.family: Config.data.theme.font.family
                font.pixelSize: Config.data.theme.font.size * 0.9
                color: Config.data.network.colors.rx
                Layout.preferredWidth: rateTextMetrics.width
                horizontalAlignment: Text.AlignRight
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.RightButton | Qt.LeftButton
        onClicked: (mouse) => (mouse.button === Qt.RightButton) && menu.popup()
    }

    AutoSizingMenu {
        id: menu
        popupType: Popup.Native
        title: "Available Interfaces"
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside | Popup.CloseOnPressOutsideParent

        AutoSizingMenu {
            title: "Select interface"

            // Group 1: Wireless
            Repeater {
                model: Network.interfaces.get(Types.Network.Wireless)
                MenuItem {
                    contentItem: Row {
                        spacing: 4
                        anchors.verticalCenter: parent.verticalCenter
                        Loader {
                            active: true
                            sourceComponent: wirelessIcon
                            onLoaded: {
                                item.color = ColorUtils.withLightness(palette.windowText, 0.4);
                                item.scale = 16;
                                item.bars = 3;
                            }
                        }
                        Text {
                            text: modelData
                            color: palette.windowText
                            font.pixelSize: Config.data.theme.font.size * 0.9
                        }
                    }
                    onTriggered: {
                        Network.setActiveInterface(modelData, Types.Network.Wireless);
                        points = [];
                    }
                }
            }

            // Separator after wireless group (only if wireless AND wired OR
            // virtual groups are not empty).
            // A Repeater must be used for the separator to be placed dynamically.
            Repeater {
                model: Network.interfaces.get(Types.Network.Wireless)?.length > 0
                    && (Network.interfaces.get(Types.Network.Wired)?.length > 0
                        || Network.interfaces.get(Types.Network.Virtual)?.length > 0)
                    ? [1] : []
                delegate: MenuSeparator {}
            }

            // Group 2: Wired
            Repeater {
                model: Network.interfaces.get(Types.Network.Wired)
                MenuItem {
                    contentItem: Row {
                        spacing: 4
                        anchors.verticalCenter: parent.verticalCenter
                        Loader {
                            active: true
                            sourceComponent: wiredIcon
                            onLoaded: {
                                item.color = ColorUtils.withLightness(palette.windowText, 0.4);
                                item.scale = 16;
                            }
                        }
                        Text {
                            text: modelData
                            color: palette.windowText
                            font.pixelSize: Config.data.theme.font.size * 0.9
                        }
                    }
                    onTriggered: {
                        Network.setActiveInterface(modelData, Types.Network.Wired);
                        points = [];
                    }
                }
            }

            // Separator after wired group (only if wired AND virtual groups are
            // not empty).
            // A Repeater must be used for the separator to be placed dynamically.
            Repeater {
                model: Network.interfaces.get(Types.Network.Wired)?.length > 0
                    && Network.interfaces.get(Types.Network.Virtual)?.length > 0
                    ? [1] : []
                delegate: MenuSeparator {}
            }

            // Group 3: Virtual
            Repeater {
                model: Network.interfaces.get(Types.Network.Virtual)
                MenuItem {
                    contentItem: Row {
                        spacing: 4
                        anchors.verticalCenter: parent.verticalCenter
                        Loader {
                            active: true
                            sourceComponent: virtualIcon
                            onLoaded: {
                                item.color = ColorUtils.withLightness(palette.windowText, 0.4);
                                item.scale = 16;
                            }
                        }
                        Text {
                            text: modelData
                            color: palette.windowText
                            font.pixelSize: Config.data.theme.font.size * 0.9
                        }
                    }
                    onTriggered: {
                        Network.setActiveInterface(modelData, Types.Network.Virtual);
                        points = [];
                    }
                }
            }
        }
    }

    HoverPopup {
        anchors.centerIn: root
        hoverTarget: root
        anchorPosition: Types.stringToPosition(Config.data.bar.position)
        contentComponent: Component {
            ColumnLayout {
                id: contentColumn
                spacing: 2

                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: `Interface: ${Network.activeInterface} (${Types.networkToString(Network.networkType)})`
                    font.family: Config.data.theme.font.family
                    font.pixelSize: Config.data.theme.font.size
                    font.bold: true
                    color: Config.data.theme.colors.foreground
                }

                Text {
                    Layout.alignment: Qt.AlignHCenter
                    font.family: Config.data.theme.font.family
                    font.pixelSize: Config.data.theme.font.size
                    color: Config.data.theme.colors.foreground
                    textFormat: Text.RichText

                    text: {
                        let rows = [
                            {
                                label: "LAN IPs",
                                value: Network.lanIPs.length ? Network.lanIPs.join("<br>") : "N/A",
                                font: Config.data.theme.fontMono.family,
                                fontSize: Config.data.theme.fontMono.size,
                            },
                            {
                                label: "WAN IP",
                                value: Network.wanIP || "N/A",
                                font: Config.data.theme.fontMono.family,
                                fontSize: Config.data.theme.fontMono.size,
                            },
                        ];

                        switch (Network.networkType) {
                        case Types.Network.Wireless:
                            rows = [
                                {
                                    label: "SSID",
                                    value: Network.ssid || "N/A",
                                    font: Config.data.theme.font.family,
                                    fontSize: Config.data.theme.font.size,
                                },
                                {
                                    label: "Signal",
                                    value: Network.signalStrength < 0 ? Network.signalStrength + " dBm" : "N/A",
                                    font: Config.data.theme.font.family,
                                    fontSize: Config.data.theme.font.size,
                                },
                                {
                                    label: "Bitrate",
                                    value: function() {
                                        let out = [];

                                        if (Network.bitrateRx > 0) {
                                            let rx = getDisplayRate(Network.bitrateRx, 'Mb', 'Mb', FileUtils.unitsMetricBit);
                                            out.push(`↓ ${rx.rate} ${rx.unit}/s`);
                                        }
                                        if (Network.bitrateTx > 0) {
                                            let tx = getDisplayRate(Network.bitrateTx, 'Mb', 'Mb', FileUtils.unitsMetricBit);
                                            out.push(`↑ ${tx.rate} ${tx.unit}/s`);
                                        }

                                        if (out.length) {
                                            return out.join("<br>");
                                        }

                                        return "N/A";
                                    }(),
                                    font: Config.data.theme.font.family,
                                    fontSize: Config.data.theme.font.size,
                                },
                            ].concat(rows);
                            break;
                        case Types.Network.Wired:
                            rows = [
                                {
                                    label: "Link speed",
                                    value: function() {
                                        if (Network.linkSpeed > 0) {
                                            let dr = getDisplayRate(Network.linkSpeed, 'Mb', 'Mb', FileUtils.unitsMetricBit);
                                            return `${dr.rate} ${dr.unit}/s`;
                                        }
                                        return "N/A";
                                    }(),
                                    font: Config.data.theme.font.family,
                                    fontSize: Config.data.theme.font.size,
                                },
                            ].concat(rows);
                            break;
                        }

                        let createRow = function(rowData) {
                            return `
<tr>
  <td align="left" width="60">${rowData.label}:</td>
  <td align="left" width="150"><span style="font-family: '${rowData.font}'; font-size: ${rowData.fontSize}px;">${rowData.value}</span></td>
</tr>`;
                        };

                        return `<table>${rows.map(r => createRow(r)).join("")}</table>`;
                    }
                }
            }
        }
    }
}
