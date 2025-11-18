import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.modules.common
import qs.modules.common.widgets
import qs.modules.common.utils
import qs.modules.icons
import qs.services

Item {
    id: root

    property real scale: Config.data.ram.scale || 1.0

    implicitWidth: (icon.visible ? icon.width : 0)
        + (graph.visible ? graph.width : 0) + 4
    implicitHeight: Config.data.bar.size - Config.data.bar.size * 0.2

    RAMIcon {
        id: icon
        visible: Config.data.ram.icon.enabled
        color: Config.data.ram.icon.color
        scale: Config.data.ram.icon.scale * root.height
        anchors.verticalCenter: parent.verticalCenter
    }

    Canvas {
        id: graph
        visible: Config.data.ram.graph.enabled
        anchors {
            top: parent.top
            bottom: parent.bottom
            right: parent.right
        }
        width: 100 * root.scale

        onPaint: {
            if (RAM.total === 0) return;

            let ctx = getContext("2d");
            ctx.clearRect(0, 0, width, height);

            let usedRatio = RAM.used / RAM.total;
            let sharedRatio = RAM.shared / RAM.total;
            let buffersCachedRatio = (RAM.buffers + RAM.cached + RAM.sreclaimable) / RAM.total;
            let freeRatio = RAM.free / RAM.total;

            // Clamp small ratios to minimum visible width
            let minVisible = 1 / width;
            usedRatio = Math.max(usedRatio, minVisible);
            sharedRatio = Math.max(sharedRatio, minVisible);
            buffersCachedRatio = Math.max(buffersCachedRatio, minVisible);
            freeRatio = Math.max(freeRatio, minVisible);

            let cumulativeX = 0;

            // Draw segments from left to right
            if (usedRatio > 0) {
                ctx.fillStyle = Config.data.ram.colors.used;
                ctx.fillRect(cumulativeX, 0, usedRatio * width, height);
                cumulativeX += usedRatio * width;
            }
            if (sharedRatio > 0) {
                ctx.fillStyle = Config.data.ram.colors.shared;
                ctx.fillRect(cumulativeX, 0, sharedRatio * width, height);
                cumulativeX += sharedRatio * width;
            }
            if (buffersCachedRatio > 0) {
                ctx.fillStyle = Config.data.ram.colors.buffersCached;
                ctx.fillRect(cumulativeX, 0, buffersCachedRatio * width, height);
                cumulativeX += buffersCachedRatio * width;
            }
            if (freeRatio > 0) {
                ctx.fillStyle = Config.data.ram.colors.free;
                ctx.fillRect(cumulativeX, 0, freeRatio * width, height);
            }
        }
    }

    Connections {
        target: RAM
        function onStatsUpdated() {
            graph.requestPaint()
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
                    text: "RAM Usage"
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
                                label: "Total",
                                source: ['total'],
                                color: Config.data.theme.colors.foreground,
                            },
                            {
                                label: "Used",
                                source: ['used'],
                                color: Config.data.ram.colors.used,
                            },
                            {
                                label: "Shared",
                                source: ['shared'],
                                color: Config.data.ram.colors.shared,
                            },
                            {
                                label: "Buff/Cache",
                                source: ['buffers', 'cached', 'sreclaimable'],
                                color: Config.data.ram.colors.buffersCached,
                            },
                            {
                                label: "Free",
                                source: ['free'],
                                color: Config.data.ram.colors.free,
                            },
                            {
                                label: "Available",
                                source: ['available'],
                                color: Config.data.theme.colors.foreground,
                            },
                        ];

                        let total = FileUtils.convertSizeUnit(RAM.total, "KiB", Config.data.ram.sizeUnit);

                        for (let i = 0; i < rows.length; ++i) {
                            let val = 0.0;
                            for (let j = 0; j < rows[i].source.length; ++j) {
                                val += RAM[rows[i].source[j]];
                            }
                            if (rows[i].label === 'Total') {
                                rows[i].value = total;
                            } else {
                                rows[i].value = FileUtils.convertSizeUnit(val, "KiB", Config.data.ram.sizeUnit);
                                rows[i].pct = (rows[i].value / total)*100;
                            }
                        }

                        let createRow = function(rowData) {
                            return `
<tr>
  <td align="left" width="60"><span style="color: ${rowData.color}">${rowData.label}</span>:</td>
  <td align="right" width="70"><span style="font-family: '${Config.data.theme.fontMono.family}'; font-size: ${Config.data.theme.fontMono.size}px;">${rowData.value.toFixed(2)}${Config.data.ram.sizeUnit}</span></td>
  <td align="right" width="60"><span style="font-family: '${Config.data.theme.fontMono.family}'; font-size: ${Config.data.theme.fontMono.size}px;">${typeof rowData.pct !== 'undefined' ? rowData.pct.toFixed(2) + "%" : ""}</span></td>
</tr>`;
                        };

                        return `<table>${rows.map(r => createRow(r)).join("")}</table>`;
                    }
                }

                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: "Top Processes"
                    font.family: Config.data.theme.font.family
                    font.pixelSize: Config.data.theme.font.size
                    font.bold: true
                    color: Config.data.theme.colors.foreground
                    Layout.topMargin: 6
                }

                Text {
                    Layout.alignment: Qt.AlignHCenter
                    font.family: Config.data.theme.fontMono.family
                    font.pixelSize: Config.data.theme.fontMono.size
                    color: Config.data.theme.colors.foreground
                    text: {
                        let out = [];
                        for (let p of RAM.topProcesses) {
                            let pidStr = p.pid.toString().padStart(6);
                            let commStr = p.comm.slice(0, 15).padEnd(15);
                            let memStr = `${p.mem.toFixed(1)}%`;
                            out.push(`${pidStr} ${commStr}\t${memStr.padStart(6)}`);
                        }
                        return out.join("\n");
                    }
                }
            }
        }
    }
}
