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
            horizontalCenterOffset: -2  // Account for battery icon nub
        }
        valueBarWidth: icon.width - icon.borderWidth * 2 - 2 // 2 for nub + margins
        valueBarHeight: icon.height - icon.borderWidth * 2
        value: percentage
        text: Math.round(value * 100)
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

        // Clip the progress bar within the borders of the icon
        layer.enabled: true
        layer.effect: OpacityMask {
            maskSource: Item {
                width: batteryProgress.width
                height: batteryProgress.height

                Rectangle {
                    x: icon.x - batteryProgress.x
                    y: icon.y - batteryProgress.y
                    width: icon.width - 3  // Exclude nub
                    height: icon.height
                    radius: 3
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
