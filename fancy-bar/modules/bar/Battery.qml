import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import Quickshell
import qs.modules.common
import qs.modules.icons
import qs.modules.common.widgets
import qs.services

MouseArea {
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
            centerIn: parent
            // Account for battery icon nub
            horizontalCenterOffset: icon.orientation === Types.Orientation.Horizontal ? -icon.nubWidth / 2 : 0
            verticalCenterOffset: icon.orientation === Types.Orientation.Vertical ? icon.nubHeight / 2 : 0
        }
        valueBarWidth: icon.bodyWidth - icon.borderWidth * 2
        valueBarHeight: icon.bodyHeight - icon.borderWidth * 2
        value: percentage
        text: Config.data.battery.showPercentage ? Math.round(value * 100) : ""
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
                    x: (batteryProgress.width - icon.bodyWidth) / 2
                    y: (batteryProgress.height - icon.bodyHeight) / 2
                    width: icon.bodyWidth
                    height: icon.bodyHeight
                    radius: icon.orientation === Types.Orientation.Vertical ? icon.width * 0.2 : icon.height * 0.2
                }
            }
        }
    }

    BatteryIcon {
        id: icon
        anchors.centerIn: parent
        width: 32
        height: 20
        iconColor: Config.data.theme.color.foreground
    }

    /*
    BatteryPopup {
        id: batteryPopup
        hoverTarget: root
    }
    */
}
