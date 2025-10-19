import QtQuick
import qs.modules.common

Item {
    id: root

    property color iconColor: "white"
    property int orientation: Types.Orientation.Horizontal
    property real size: 1

    readonly property real borderWidth: size * 0.05
    readonly property real bodyWidth: body.width
    readonly property real bodyHeight: body.height
    readonly property real bodyRadius: body.radius

    state: Types.orientationToString(orientation)
    width: orientation === Types.Orientation.Horizontal ? size : size * 0.6
    height: orientation === Types.Orientation.Vertical ? size : size * 0.6

    Rectangle {
        id: body
        color: "transparent"
        border.color: root.iconColor
        border.width: root.borderWidth
        radius: root.size * 0.1
    }

    Rectangle {
        id: nub
        color: root.iconColor
        radius: 0
    }

    states: [
        State {
            name: "horizontal"
            AnchorChanges {
                target: body
                anchors.left: parent.left
                anchors.right: nub.left
                anchors.verticalCenter: parent.verticalCenter
            }
            AnchorChanges {
                target: nub
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
            }
            PropertyChanges {
                target: body
                width: root.width * 0.9
                height: root.height
            }
            PropertyChanges {
                target: nub
                width: root.size * 0.1
                height: root.size * 0.2
                topRightRadius: root.size * 0.1
                bottomRightRadius: root.size * 0.1
            }
        },
        State {
            name: "vertical"
            AnchorChanges {
                target: body
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: nub.bottom
                anchors.bottom: parent.bottom
            }
            AnchorChanges {
                target: nub
                anchors.top: parent.top
                anchors.horizontalCenter: parent.horizontalCenter
            }
            PropertyChanges {
                target: body
                width: root.width
                height: root.height * 0.9
            }
            PropertyChanges {
                target: nub
                width: root.size * 0.2
                height: root.size * 0.1
                topLeftRadius: root.size * 0.1
                topRightRadius: root.size * 0.1
            }
        }
    ]
}
