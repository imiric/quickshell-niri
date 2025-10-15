import QtQuick
import qs.modules.common

Row {
    spacing: 5
    Image {
        anchors.verticalCenter: parent.verticalCenter
        source: niri.focusedWindow?.iconPath ? "file://" + niri.focusedWindow?.iconPath : ""
        sourceSize.width: Config.data.focusedWindow.icon.size_factor * Config.data.theme.widget.size
        sourceSize.height: Config.data.focusedWindow.icon.size_factor * Config.data.theme.widget.size
        visible: Config.data.focusedWindow.icon.enabled && niri.focusedWindow?.iconPath !== ""
        smooth: true
    }

    // Fallback for missing icons
    Rectangle {
        anchors.verticalCenter: parent.verticalCenter
        width: Config.data.focusedWindow.icon.size_factor * Config.data.theme.widget.size
        height: Config.data.focusedWindow.icon.size_factor * Config.data.theme.widget.size
        color: "#CCC"
        visible: Config.data.focusedWindow.icon.enabled && niri.focusedWindow?.iconPath === ""
        radius: 12
    }

    Text {
        anchors.verticalCenter: parent.verticalCenter
        text: niri.focusedWindow?.title ?? ""
        font.family: Config.data.focusedWindow.font.family || Config.data.theme.font.family
        font.pixelSize: Config.data.focusedWindow.font.size_factor * Config.data.theme.font.size
        font.weight: Config.data.focusedWindow.font.weight
        color: Config.data.theme.color.text
        visible: Config.data.focusedWindow.title.enabled
    }
}
