pragma Singleton
import QtQuick
import Niri

Niri {
    id: niri

    Component.onCompleted: connect()

    onConnected: console.info("Connected to niri")
    onErrorOccurred: function(error) {
        console.error("Niri error:", error)
    }
}
