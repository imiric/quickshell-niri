import QtQuick
import QtQuick.Layouts
import Quickshell

Rectangle {
    SystemClock {
        id: clock
        precision: SystemClock.Seconds
    }
    Text {
        id: timeBlock
        anchors {
            verticalCenter: parent.verticalCenter
        }
        text: Qt.formatDateTime(clock.date, "hh:mm dd MMM, yyyy")
        color: "#666666"
        font.family: "Barlow Medium"
        font.pixelSize: 16
        Component.onCompleted: {
            parent.width = timeBlock.contentWidth
        }
    }
}
