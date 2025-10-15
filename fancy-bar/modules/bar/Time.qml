import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.modules.common

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

        text: Qt.formatDateTime(clock.date, Config.data.time.format)
        font.family: Config.data.time.font.family || Config.data.theme.font.family
        font.pixelSize: Config.data.time.font.size_factor * Config.data.theme.font.size
        font.weight: Config.data.time.font.weight
        color: Config.data.theme.color.text_muted
        visible: Config.data.time.enabled

        Component.onCompleted: {
            // For some reason this is always too wide, so the -30 normalizes it.
            parent.width = timeBlock.contentWidth - 30
        }
    }
}
