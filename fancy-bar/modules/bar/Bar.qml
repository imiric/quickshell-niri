import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.modules.common

PanelWindow {
    id: bar
    implicitHeight: Config.data.bar.size
    color: "transparent"
    property string position: Config.data.bar.position

    anchors {
        top: position === "top"
        bottom: position === "bottom"
        left: true
        right: true
    }

    Rectangle {
        anchors.fill: parent
        color: Config.data.theme.color.background

        RowLayout {
            id: leftLayout
            anchors {
                left: parent.left
                leftMargin: 25
            }
            Loader { active: Config.data.workspaces.enabled; sourceComponent: Workspaces {} }
        }

        RowLayout {
            id: centerLayout

            anchors {
                left: leftLayout.right
                leftMargin: 5
                verticalCenter: parent.verticalCenter
            }
            Loader { active: Config.data.focusedWindow.enabled; sourceComponent: FocusedWindow {} }

        }

        RowLayout {
            id: rightLayout

            anchors {
                verticalCenter: parent.verticalCenter
                right: parent.right
                rightMargin: 25
            }
            spacing: 10
            Loader {
                active: Config.data.battery.enabled
                sourceComponent: Battery {
                    orientation: Types.stringToOrientation(Config.data.battery.orientation)
                }
            }
            Loader { active: Config.data.time.enabled; sourceComponent: Time {} }
        }
    }
}
