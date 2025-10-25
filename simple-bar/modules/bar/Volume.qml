import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Pipewire

Item {
    PwObjectTracker {
        objects: [Pipewire.defaultAudioSink]
    }

    property var sink: Pipewire.defaultAudioSink
    property real volume: sink?.audio?.volume ?? 0
    property bool muted: sink?.audio?.muted ?? false

    implicitWidth: volumeLayout.implicitWidth
    implicitHeight: volumeLayout.implicitHeight

    RowLayout {
        id: volumeLayout
        anchors.fill: parent
        spacing: 6

        // Icon
        Text {
            text: muted ? "" : "󰕾" // Mute icon when muted, volume icon otherwise
            color: "#999999"
            font.family: "Symbols Nerd Font"
            font.pixelSize: 16
        }

        // Percent text
        Text {
            text: {
                var vol = Number(volume);
                if (isNaN(vol) || !isFinite(vol)) {
                    return "0%";
                }
                return Math.round(vol * 100) + "%";
            }
            color: muted ? "#ff0000" : "#999999"
            font.family: "Barlow Medium"
            font.pixelSize: 16
        }
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        onClicked: {
            if (sink && sink.audio) {
                sink.audio.muted = !sink.audio.muted;
            }
        }

        onWheel: function(wheel) {
            if (sink && sink.audio) {
                var delta = wheel.angleDelta.y / 120; // Standard wheel delta
                var newVolume = volume + (delta * 0.05); // Change by 5% per scroll step
                newVolume = Math.max(0, Math.min(1.5, newVolume)); // Clamp between 0 and 1
                sink.audio.volume = newVolume;
            }
        }
    }
}