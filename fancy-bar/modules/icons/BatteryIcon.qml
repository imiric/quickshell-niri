import QtQuick
import qs.modules.common

Item {
    id: root

    property color iconColor: "white"
    property real borderWidth: 2
    property int orientation: Types.Orientation.Horizontal

    readonly property real nubWidth: batteryNub.width
    readonly property real nubHeight: batteryNub.height
    readonly property real bodyWidth: batteryBody.width
    readonly property real bodyHeight: batteryBody.height

    state: orientation === Types.Orientation.Vertical ? "vertical" : "horizontal"

    Rectangle {
        id: batteryBody
        color: "transparent"
        border.color: root.iconColor
        border.width: root.borderWidth
    }

    Rectangle {
        id: batteryNub
        color: root.iconColor
    }

    states: [
        State {
            name: "horizontal"
            AnchorChanges {
                target: batteryBody
                anchors.left: parent.left
                anchors.right: batteryNub.left
                anchors.verticalCenter: parent.verticalCenter
            }
            PropertyChanges {
                target: batteryBody
                height: parent.height
                radius: parent.height * 0.2
            }
            AnchorChanges {
                target: batteryNub
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
            }
            PropertyChanges {
                target: batteryNub
                width: parent.height * 0.2
                height: parent.height * 0.4
                radius: 0
                topRightRadius: parent.height * 0.1
                bottomRightRadius: parent.height * 0.1
            }
        },
        State {
            name: "vertical"
            AnchorChanges {
                target: batteryBody
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: batteryNub.bottom
                anchors.bottom: parent.bottom
            }
            PropertyChanges {
                target: batteryBody
                radius: parent.width * 0.2
            }
            AnchorChanges {
                target: batteryNub
                anchors.top: parent.top
                anchors.horizontalCenter: parent.horizontalCenter
            }
            PropertyChanges {
                target: batteryNub
                width: parent.width * 0.4
                height: parent.width * 0.2
                radius: 0
                topLeftRadius: parent.width * 0.1
                topRightRadius: parent.width * 0.1
            }
        }
    ]
}
