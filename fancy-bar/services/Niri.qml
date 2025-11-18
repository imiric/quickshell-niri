pragma Singleton
import QtQuick
import Niri 0.1

Niri {
    id: niri

    Component.onCompleted: connect()

    onConnected: console.info("Connected to niri")
    onErrorOccurred: function(error) {
        console.error("Niri error:", error)
    }
}
