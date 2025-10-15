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
                Layout.alignment: Qt.AlignVCenter
                source: niri.focusedWindow?.iconPath ? "file://" + niri.focusedWindow?.iconPath : ""
                sourceSize.width: 24
                sourceSize.height: 24
                visible: Config.data.application.icon.enabled && niri.focusedWindow?.iconPath !== ""
                smooth: true
            }

            // Fallback for missing icons
            Rectangle {
                Layout.alignment: Qt.AlignVCenter
                width: 24
                height: 24
                color: "#CCC"
                visible: Config.data.application.icon.enabled && niri.focusedWindow?.iconPath === ""
                radius: 12
            }

            Text {
                Layout.alignment: Qt.AlignVCenter
                text: niri.focusedWindow?.title ?? ""
                font.family: Config.data.application.font.family || Config.data.theme.font.family
                font.pixelSize: Config.data.application.font.size_factor * Config.data.theme.font.size
                font.weight: Config.data.application.font.weight
                color: Config.data.theme.color.text
                visible: Config.data.application.title.enabled
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
