import QtQuick
import QtQuick.Controls
import qs.modules.common.utils

/**
 * A progress bar with optional text centered inside it.
 * Partially based on https://github.com/end-4/dots-hyprland/blob/449df7f161e6435569bc7d9499b2e444dd8aa153/dots/.config/quickshell/ii/modules/common/widgets/ClippedProgressBar.qml
 */
ProgressBar {
    id: root
    property bool vertical: false
    property real valueBarWidth: 30
    property real valueBarHeight: 18
    property color highlightColor: "gray"
    property color trackColor: Color.transparentize(highlightColor, 0.7)
    property alias radius: contentItem.radius
    property color textColor: "white"
    property string text

    font.weight: text.length > 2 ? Font.Medium : Font.DemiBold

    background: Item {
        implicitHeight: valueBarHeight
        implicitWidth: valueBarWidth
    }

    contentItem: Rectangle {
        id: contentItem
        anchors.fill: parent
        color: root.trackColor

        Rectangle {
            id: progressFill
            color: root.highlightColor
            anchors {
                top: parent.top
                bottom: parent.bottom
                left: parent.left
                right: undefined
            }
            width: parent.width * root.visualPosition
            height: parent.height

            states: State {
                name: "vertical"
                when: root.vertical
                AnchorChanges {
                    target: progressFill
                    anchors {
                        top: undefined
                        bottom: parent.bottom
                        left: parent.left
                        right: parent.right
                    }
                }
                PropertyChanges {
                    target: progressFill
                    width: parent.width
                    height: parent.height * root.visualPosition
                }
            }
        }
    }

    Text {
        id: overlayText
        anchors.centerIn: parent
        font: root.font
        text: root.text
        color: textColor
        opacity: 0.5
        verticalAlignment: Text.AlignVCenter
        style: Text.Outline
    }
}
