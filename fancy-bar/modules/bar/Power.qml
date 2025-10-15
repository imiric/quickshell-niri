import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.UPower
import qs.modules.common

Rectangle {
    Text {
        id: powerDisplay
        anchors {
            verticalCenter: parent.verticalCenter
        }

        text: Number(UPower.displayDevice.percentage * 100).toFixed(2) + "%"
        font.family: Config.data.power.font.family || Config.data.theme.font.family
        font.pixelSize: Config.data.power.font.size_factor * Config.data.theme.font.size
        font.weight: Config.data.power.font.weight
        color: Config.data.theme.color.text
        visible: Config.data.power.enabled

        Component.onCompleted: {
            parent.width = powerDisplay.contentWidth
        }
    }
}
