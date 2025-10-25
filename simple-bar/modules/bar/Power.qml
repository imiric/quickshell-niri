import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.UPower

Rectangle {
    // Keep background transparent so it doesn't show a white box behind the text
    color: "transparent"
    Row {
        id: powerRow
        anchors.verticalCenter: parent.verticalCenter
        spacing: 6

        Text {
            id: powerIcon
            text: "󰄌"
            color: "#999999"
            font.pixelSize: 16
            // Leave font.family unset so icon glyph can come from an icon/nerd font via fallback.
        }

        Text {
            id: powerPercent
            text: Number(UPower.displayDevice.percentage * 100).toFixed(0) + "%"
            color: "#999999"
            font.family: "Barlow Medium"
            font.pixelSize: 16
        }
    }

    // Bind the Rectangle size to the row content so layout spacing is consistent
    implicitWidth: powerRow.implicitWidth
    implicitHeight: powerRow.implicitHeight
}
