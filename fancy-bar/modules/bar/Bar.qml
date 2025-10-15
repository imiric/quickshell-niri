import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.modules.common

PanelWindow {
    id: bar
    anchors {
        top: true
        left: true
        right: true
    }
    implicitHeight: 30
    color: "transparent"

    Rectangle {
        anchors.fill: parent
        color: Config.data.theme.color.background
        bottomLeftRadius: 20
        bottomRightRadius: 20
        // left
        RowLayout {
            id: leftLayout
            anchors {
                left: parent.left
                leftMargin: 25
            }
            Loader { active: true; sourceComponent: Workspaces {} }
        }
        // center
        RowLayout {
            id: centerLayout

            anchors {
                left: leftLayout.right
                leftMargin: 5
                verticalCenter: parent.verticalCenter
            }
            Loader { active: true; sourceComponent: FocusedWindow {} }

        }
        // right
        RowLayout {
            id: rightLayout

            anchors {
                verticalCenter: parent.verticalCenter
                right: parent.right
                rightMargin: 25
            }
            spacing: 10
            Loader { active: true; sourceComponent: Power {} }
            Loader { active: true; sourceComponent: Time {} }
        }
    }
}
