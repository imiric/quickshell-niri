import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.modules.common

// Clock component that displays time and date in a vertically stacked
// layout, with both blocks horizontally centered along the same axis. The width
// and height of the blocks is dynamically determined to avoid layout shifting
// with proportional fonts as digits change, and to make the shorter block
// slightly larger to compensate.
Item {
    id: root
    property real size: 1

    SystemClock {
        id: clock
        precision: SystemClock.Seconds
    }

    implicitWidth: contentItem.implicitWidth
    implicitHeight: size

    // Fixed-width blocks used as width references for the actual time and date blocks.
    // The reference isn't perfect, but should look good in most cases.
    TextMetrics {
        id: timeMetrics
        font: timeBlock.font
        text: Qt.formatDateTime(new Date(2000, 12, 30, 23, 59, 59),
                                Config.data.clock.time.format || "hh:mm")
    }

    TextMetrics {
        id: dateMetrics
        font: dateBlock.font
        text: Qt.formatDateTime(new Date(2000, 12, 30),
                                Config.data.clock.date.format || "yyyy-MM-dd")
    }

    ColumnLayout {
        id: contentItem
        anchors.centerIn: parent
        width: Math.max(timeBlock.Layout.preferredWidth, dateBlock.Layout.preferredWidth)
        height: parent.height
        spacing: gapSize

        Text {
            id: timeBlock
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredHeight: (root.size - gapSize) / 2
            Layout.preferredWidth: timeMetrics.advanceWidth

            text: Qt.formatDateTime(clock.date, Config.data.clock.time.format || "hh:mm")
            font.family: Config.data.clock.font.family || Config.data.theme.font.family
            font.pixelSize: baseFontSize * timeScale
            font.weight: Config.data.clock.font.weight
            color: Config.data.theme.colors.textMuted
            visible: Config.data.clock.time.enabled !== false
            verticalAlignment: Text.AlignVCenter
        }

        Text {
            id: dateBlock
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredHeight: (root.size - gapSize) / 2
            Layout.preferredWidth: dateMetrics.advanceWidth

            text: Qt.formatDateTime(clock.date, Config.data.clock.date.format || "yyyy-MM-dd")
            font.family: Config.data.clock.font.family || Config.data.theme.font.family
            font.pixelSize: baseFontSize * dateScale
            font.weight: Config.data.clock.font.weight
            color: Config.data.theme.colors.textMuted
            visible: Config.data.clock.date.enabled !== false
            verticalAlignment: Text.AlignVCenter
        }
    }

    readonly property real baseFontSize: {
        (timeBlock.visible && dateBlock.visible ? 0.5 : 1)
            * size * Config.data.clock.font.scale
    }
    readonly property real maxBlockHeight: size - gapSize
    readonly property real gapSize: size * 0.1
    property real timeScale: 1
    property real dateScale: 1

    Component.onCompleted: {
        if (!timeBlock.visible || !dateBlock.visible) return;

        const timeWidth = timeBlock.contentWidth;
        const dateWidth = dateBlock.contentWidth;

        // Give narrower block a boost
        let targetTimeScale = dateWidth > timeWidth ? 1.3 : 1;
        let targetDateScale = timeWidth > dateWidth ? 1.3 : 1;

        timeScale = targetTimeScale;
        dateScale = targetDateScale;

        // Scale down if either block is too tall
        if (timeBlock.contentHeight > maxBlockHeight) {
            timeScale *= maxBlockHeight / timeBlock.contentHeight;
        }
        if (dateBlock.contentHeight > maxBlockHeight) {
            dateScale *= maxBlockHeight / dateBlock.contentHeight;
        }

        // Ensure scaled block doesn't exceed the widest block's width
        const maxWidth = Math.max(timeWidth, dateWidth);
        if (timeBlock.contentWidth > maxWidth) {
            timeScale *= maxWidth / timeBlock.contentWidth;
        }
        if (dateBlock.contentWidth > maxWidth) {
            dateScale *= maxWidth / dateBlock.contentWidth;
        }
    }
}
