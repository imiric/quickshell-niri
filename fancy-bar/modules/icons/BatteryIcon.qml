import QtQuick

Item {
    id: root

    property color iconColor: "white"
    property real borderWidth: 2

    Rectangle {
        id: batteryBody
        anchors {
            left: parent.left
            right: batteryNub.left
            verticalCenter: parent.verticalCenter
        }
        height: parent.height
        radius: 3
        color: "transparent"
        border.color: root.iconColor
        border.width: root.borderWidth
    }

    Rectangle {
        id: batteryNub
        anchors {
            right: parent.right
            verticalCenter: parent.verticalCenter
        }
        width: 3
        height: parent.height * 0.5
        radius: 1.5
        color: root.iconColor
    }
}
