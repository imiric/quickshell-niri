import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import Quickshell
import qs.modules.common
import qs.modules.common.widgets
import qs.modules.icons
import qs.services

MouseArea {
    id: root

    property int orientation: Types.Orientation.Horizontal
    property real size: 1

    readonly property var chargeState: Battery.chargeState
    readonly property bool isCharging: Battery.isCharging
    readonly property bool isPluggedIn: Battery.isPluggedIn
    readonly property real percentage: Battery.percentage
    readonly property bool isLow: percentage <= Config.data.battery.low / 100
    readonly property bool isCritical: percentage <= Config.data.battery.critical / 100

    implicitWidth: batteryProgress.implicitWidth

    hoverEnabled: true

    ProgressBarText {
        id: batteryProgress
        anchors {
            left: icon.left
            bottom: icon.bottom
        }
        valueBarWidth: icon.bodyWidth
        valueBarHeight: icon.bodyHeight
        value: percentage
        text: Config.data.battery.showPercentage ? Math.round(value * 100) : ""
        orientation: root.orientation
        shimmer: isCharging
        pulse: isCharging
        highlightColor: (() => {
            if (isCritical && !isCharging) {
                return Config.data.theme.color.error;
            }
            if (isLow && !isCharging) {
                return Config.data.theme.color.warning;
            }
            return Config.data.theme.color.ok;
        })()
        font.family: "Noto Sans"
        font.pixelSize: 14
        textColor: Config.data.theme.color.foreground

        // Clip the progress bar within the borders of the battery icon body
        layer.enabled: true
        layer.effect: OpacityMask {
            maskSource: Item {
                width: batteryProgress.width
                height: batteryProgress.height

                Rectangle {
                    x: icon.borderWidth
                    y: icon.borderWidth
                    width: icon.bodyWidth - icon.borderWidth * 2
                    height: icon.bodyHeight - icon.borderWidth * 2
                    radius: icon.bodyRadius / 2
                }
            }
        }
    }

    BatteryIcon {
        id: icon
        anchors.centerIn: parent
        size: Math.min(Config.data.battery.scale * Config.data.theme.widget.size,
                       Config.data.bar.size)
        iconColor: Config.data.theme.color.foreground
        orientation: root.orientation
    }

    /*
    BatteryPopup {
        id: batteryPopup
        hoverTarget: root
    }
    */
}
