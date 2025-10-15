import QtQuick
import QtQuick.Layouts
import Quickshell

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
        color: "#222222"
        bottomLeftRadius: 20
        bottomRightRadius: 20
        // left
        RowLayout {
            id: workspaceLayout
            anchors {
                left: parent.left
                leftMargin: 25
            }
            Loader { active: true; sourceComponent: Workspaces {} }
        }
        // center
        RowLayout {
            spacing: 5

            anchors {
                left: workspaceLayout.right
                leftMargin: 5
                verticalCenter: parent.verticalCenter
            }

            Image {
                source: niri.focusedWindow?.iconPath ? "file://" + niri.focusedWindow?.iconPath : ""
                sourceSize.width: 24
                sourceSize.height: 24
                visible: niri.focusedWindow?.iconPath !== ""
                smooth: true
            }

            // Fallback for missing icons
            Rectangle {
                width: 24
                height: 24
                color: "#CCC"
                visible: niri.focusedWindow?.iconPath === ""
                radius: 12
            }

            Text {
                text: niri.focusedWindow?.title ?? ""
                font.family: "Barlow Medium"
                font.pixelSize: 16
                color: "#999999"
            }
        }
        // right
        RowLayout {
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
