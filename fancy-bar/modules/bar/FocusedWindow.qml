import QtQuick
import qs.modules.common
import qs.services

Row {
    spacing: 4
    Image {
        anchors.verticalCenter: parent.verticalCenter
        source: Niri.focusedWindow?.iconPath ? "file://" + Niri.focusedWindow?.iconPath : ""
        sourceSize.width: Config.data.focusedWindow.icon.scale * Config.data.theme.widget.size
        sourceSize.height: Config.data.focusedWindow.icon.scale * Config.data.theme.widget.size
        visible: Config.data.focusedWindow.icon.enabled && Niri.focusedWindow?.iconPath !== ""
        smooth: true
    }

    // Fallback for missing icons
    Rectangle {
        anchors.verticalCenter: parent.verticalCenter
        width: Config.data.focusedWindow.icon.scale * Config.data.theme.widget.size
        height: Config.data.focusedWindow.icon.scale * Config.data.theme.widget.size
        color: "#CCC"
        visible: Config.data.focusedWindow.icon.enabled && Niri.focusedWindow?.iconPath === ""
        radius: 12
    }

    Text {
        // FIXME: Make the width proportional to the width of the container.
        width: 1000
        elide: Text.ElideRight
        anchors.verticalCenter: parent.verticalCenter
        text: Niri.focusedWindow?.title ?? ""
        font.family: Config.data.focusedWindow.font.family || Config.data.theme.font.family
        font.pixelSize: Config.data.focusedWindow.font.scale * Config.data.theme.font.size
        font.weight: Config.data.focusedWindow.font.weight
        color: Config.data.theme.colors.text
        visible: Config.data.focusedWindow.title.enabled
    }
}
