import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.modules.common
import qs.modules.common.utils
import qs.modules.common.widgets
import qs.modules.icons
import qs.services

Item {
    id: root

    property real scale: Config.data.cpu.scale || 1.0
    property real history: Config.data.cpu.graph.history || 60  // Seconds
    property real updateInterval: Config.data.cpu.updateInterval || 1000  // Milliseconds
    property color lineColor: Config.data.cpu.graph.lineColor
    property color lowUsageColor: Config.data.cpu.graph.lowUsageColor
    property color highUsageColor: Config.data.cpu.graph.highUsageColor
    readonly property color mixedUsageColor: ColorUtils.mix(lowUsageColor, highUsageColor)

    implicitWidth: (icon.visible ? icon.width : 0)
        + (graph.visible ? graph.width : 0) + 4
    implicitHeight: Config.data.bar.size - Config.data.bar.size * 0.2

    // Buffer for graph points (rolling window)
    property var points: []

    // Initial dummy point to avoid empty graph
    Component.onCompleted: {
        if (!graph.visible) return;
        points.push({ x: Date.now(), y: 0.0 });
        graph.requestPaint();
    }

    Timer {
        interval: updateInterval
        running: Config.data.cpu.graph.enabled
        repeat: true
        onTriggered: updateGraph()
    }

    function updateGraph() {
        // Add new point
        let x = Date.now();
        let y = CPU.overallUsage;
        points.push({ x: x, y: y });

        // Clean old points beyond history
        let cutoff = Date.now() - history * 1000;
        while (points.length > 0 && points[0].x < cutoff) {
            points.splice(0, 1);
        }

        graph.requestPaint();
    }

    CPUIcon {
        id: icon
        visible: Config.data.cpu.icon.enabled
        color: Config.data.cpu.icon.color
        scale: Config.data.cpu.icon.scale * root.height
        anchors.verticalCenter: parent.verticalCenter
    }

    Canvas {
        id: graph
        visible: Config.data.cpu.graph.enabled
        anchors {
            top: parent.top
            bottom: parent.bottom
            right: parent.right
        }
        width: 100 * root.scale

        onPaint: {
            let ctx = getContext("2d");
            ctx.clearRect(0, 0, width, height);

            let range = history * 1000;
            let currentTime = Date.now();
            let minTime = currentTime - range;
            let visiblePoints = points.filter(function(p) { return p.x >= minTime; });

            if (visiblePoints.length < 2) return;

            // Margin to avoid graph cutoff at top/bottom
            let margin = 2;
            let effectiveHeight = height - 2 * margin;

            ctx.strokeStyle = lineColor;
            ctx.lineWidth = 2;

            let gradient = ctx.createLinearGradient(0, height, 0, 0);  // Vertical from bottom to top
            gradient.addColorStop(0, lowUsageColor);
            gradient.addColorStop(0.5, mixedUsageColor);
            gradient.addColorStop(0.9, highUsageColor);
            ctx.fillStyle = gradient;

            // Draw fill under the line first (closed path)
            ctx.beginPath();
            ctx.moveTo(0, height+10);  // Start bottom-left
            for (let i = 0; i < visiblePoints.length; ++i) {
                let px = ((visiblePoints[i].x - minTime) / range) * width;
                let py = margin + (1 - visiblePoints[i].y) * effectiveHeight;
                if (i === 0) ctx.lineTo(px, py);
                ctx.lineTo(px, py);
            }
            ctx.lineTo(width, height);  // Bottom-right
            ctx.closePath();
            ctx.fill();

            // Draw stroke on top of the line (separate path)
            ctx.beginPath();
            for (let i = 0; i < visiblePoints.length; ++i) {
                let px = ((visiblePoints[i].x - minTime) / range) * width;
                let py = margin + (1 - visiblePoints[i].y) * effectiveHeight;
                if (i === 0) ctx.moveTo(px, py);
                ctx.lineTo(px, py);
            }
            ctx.stroke();
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
                    text: "Load Average"
                    font.family: Config.data.theme.font.family
                    font.pixelSize: Config.data.theme.font.size
                    font.bold: true
                    color: Config.data.theme.colors.foreground
                }

                Text {
                    Layout.alignment: Qt.AlignHCenter
                    font.family: Config.data.theme.fontMono.family
                    font.pixelSize: Config.data.theme.fontMono.size
                    color: Config.data.theme.colors.foreground
                    text: {
                        let names = ['1m', '5m', '15m'];
                        let out = [];
                        for (let i = 0; i < CPU.loadAvg.length; ++i) {
                            let name = `${names[i]}:`.padStart(5).padEnd(6);
                            let val = CPU.loadAvg[i].toFixed(2);
                            out.push(`${name}${val}`);
                        }
                        return out.join("\n")
                    }
                }

                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: "CPU Core Usage"
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
                        for (let i = 0; i < CPU.coreUsages.length; ++i) {
                            let coreNum = `Core ${i+1}:`.padEnd(10);
                            let coreUsage = CPU.coreUsages[i].toFixed(2);
                            out.push(`${coreNum}${coreUsage}`);
                        }
                        return out.join("\n");
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
                        for (let p of CPU.topProcesses) {
                            let pidStr = p.pid.toString().padStart(6);
                            let commStr = p.comm.slice(0, 15).padEnd(15);
                            let cpuStr = `${p.cpu.toFixed(1)}%`;
                            out.push(`${pidStr} ${commStr}\t${cpuStr.padStart(6)}`);
                        }
                        return out.join("\n");
                    }
                }
            }
        }
    }
}
