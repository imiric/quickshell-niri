import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.modules.common
import qs.services

Rectangle {
    id: root

    implicitWidth: row.width + 20
    implicitHeight: Config.data.bar.size - Config.data.bar.size * 0.25
    color: Config.data.theme.colors.background2
    radius: 50

    Component.onCompleted: {
        Niri.workspaces.maxCount = Config.data.workspaces.maxCount;
    }

    Row {
        id: row
        anchors.centerIn: parent
        spacing: 8

        Repeater {
            model: Niri.workspaces

            Item {
                implicitWidth: 10
                implicitHeight: 10

                Rectangle {
                    anchors.fill: parent
                    radius: 5
                    color: (model.isActive || model.activeWindowId > 0)
                        ? Config.data.workspaces.colors.active
                        : Config.data.workspaces.colors.inactive;
                    opacity: model.isActive ? 1.0 : 0.5
                    scale: model.isActive ? 1.25 : 1.0

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: Niri.focusWorkspaceById(model.id)
                    }

                    Behavior on scale {
                        PropertyAnimation {
                            duration: 150
                            easing.type: Easing.InOutQuad
                        }
                    }

                    Behavior on opacity {
                        NumberAnimation { duration: 150 }
                    }
                }
            }
        }
    }
}
