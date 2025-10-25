import QtQuick
import QtQuick.Layouts
import Quickshell

Rectangle {
    // Make the background transparent so the parent bar color shows through
    color: "transparent"
    SystemClock {
        id: clock
        precision: SystemClock.Seconds
    }
    Text {
        id: timeBlock
        anchors {
            verticalCenter: parent.verticalCenter
        }
        text: {
            var d = clock.date;
            if (!d) return "";
            var hours = d.getHours();
            var ampm = hours >= 12 ? "PM" : "AM";
            var h = hours % 12;
            if (h === 0) h = 12;
            var mins = d.getMinutes();
            var minsStr = mins < 10 ? "0" + mins : mins;
            return h + ":" + minsStr + " " + ampm + " " + Qt.formatDate(d, "dd MMM, yyyy");
        }
        color: "#c4a912"
        font.family: "Barlow Medium"
        font.pixelSize: 16
        // Use implicit sizing so the parent Rectangle's size follows the text
        // Binding to contentWidth/contentHeight ensures the layout updates
        // when fonts or the clock become available (avoids race at startup).
    }

    implicitWidth: timeBlock.contentWidth
    implicitHeight: timeBlock.contentHeight
}
