import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Services.UPower
import qs.modules.common
import qs.modules.common.widgets
import qs.modules.icons
import qs.services

Item {
    id: root

    property int orientation: Types.Orientation.Horizontal

    readonly property var chargeState: Battery.chargeState
    readonly property bool isCharging: Battery.isCharging
    readonly property bool isPluggedIn: Battery.isPluggedIn
    readonly property real percentage: Battery.percentage
    readonly property bool isLow: percentage <= Config.data.battery.low / 100
    readonly property bool isCritical: percentage <= Config.data.battery.critical / 100

    implicitWidth: icon.width
    implicitHeight: icon.height

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
                return Config.data.theme.colors.error;
            }
            if (isLow && !isCharging) {
                return Config.data.theme.colors.warning;
            }
            return Config.data.theme.colors.ok;
        })()
        font.family: "Noto Sans"
        font.bold: true
        font.pixelSize: Config.data.theme.font.size * Config.data.battery.scale * 0.7
        textColor: Config.data.theme.colors.foreground

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
        iconColor: Config.data.theme.colors.foreground
        orientation: root.orientation
    }

    HoverPopup {
        anchors.centerIn: icon
        hoverTarget: icon
        anchorPosition: Types.stringToPosition(Config.data.bar.position)
        contentComponent: Component {
            ColumnLayout {
                id: contentColumn
                spacing: 4

                Text {
                    text: {
                        if (Battery.energyRate > 0) {
                            const status = (() => {
                                if (Battery.isCharging) return "Charging";
                                if (Battery.chargeState == UPowerDeviceState.Discharging) return "Discharging";
                                return "Unknown";
                            })();
                            return status + ": " + Battery.energyRate.toFixed(1) + "W";
                        } else {
                            const state = Battery.chargeState;
                            if (state == UPowerDeviceState.FullyCharged) return "Fully charged";
                            if (state == UPowerDeviceState.PendingCharge) return "Plugged in (not charging)";
                            if (state == UPowerDeviceState.Discharging) return "On battery";
                            return "Unknown";
                        }
                    }
                    color: Config.data.theme.colors.foreground
                    font.family: Config.data.theme.font.family
                    font.pixelSize: Config.data.theme.font.size
                }

                Text {
                    text: {
                        if (Battery.isCharging) {
                            const hours = Math.floor(Battery.timeToFull / 3600);
                            const minutes = Math.floor((Battery.timeToFull % 3600) / 60);
                            return "Time to full: " + hours + "h " + minutes + "m";
                        } else {
                            const hours = Math.floor(Battery.timeToEmpty / 3600);
                            const minutes = Math.floor((Battery.timeToEmpty % 3600) / 60);
                            return "Time remaining: " + hours + "h " + minutes + "m";
                        }
                    }
                    color: Config.data.theme.colors.foreground
                    font.family: Config.data.theme.font.family
                    font.pixelSize: Config.data.theme.font.size
                    visible: Battery.energyRate > 0 && ((Battery.isCharging && Battery.timeToFull > 0) || (!Battery.isCharging && Battery.timeToEmpty > 0))
                }
            }
        }
    }
}
