import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.modules.common

Rectangle {
    anchors.left: parent.left
    color: Config.data.theme.color.background2
    height: 25
    width: 215
    bottomLeftRadius: 10
    bottomRightRadius: 10

    Rectangle {
        anchors {
            verticalCenter: parent.verticalCenter
            left: parent.left
            right: parent.right
            leftMargin: 10
            rightMargin: 10
        }

        RowLayout {
            anchors {
                verticalCenter: parent.verticalCenter
            }
            spacing: 5

            Repeater {
                model: niri.workspaces

                Rectangle {
                    visible: index < 11
                    width: Config.data.workspaces.icon.size_factor * Config.data.theme.widget.size
                    height: Config.data.workspaces.icon.size_factor * Config.data.theme.widget.size
                    radius: Config.data.workspaces.icon.size_factor * Config.data.theme.widget.size * Config.data.workspaces.icon.radius
                    color: model.isActive ? Config.data.theme.color.active : Config.data.theme.color.inactive
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: niri.focusWorkspaceById(model.id)
                    }
                }
            }
        }
    }
}
