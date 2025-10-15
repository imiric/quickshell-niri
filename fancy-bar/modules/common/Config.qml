pragma Singleton
import Quickshell
import Quickshell.Io

Singleton {
    property var data: adapter

    FileView {
        path: Quickshell.shellPath("config.json")
        watchChanges: true
        onFileChanged: reload()
        onAdapterUpdated: writeAdapter()

        JsonAdapter {
            id: adapter

            // Global theme. Source of default and base values for all widgets.
            property JsonObject theme: JsonObject {
                property JsonObject color: JsonObject {
                   property string active: "#000000"
                   property string inactive: "#333333"
                   property string text: "#999999"
                   property string text_muted: "#777777"
                   property string background: "#222222"
                   property string background2: "#666666"
                }
                property JsonObject font: JsonObject {
                    property string family: "Sans"
                    property real size: 14
                }
                property JsonObject widget: JsonObject {
                    property real size: 24
                }
            }

            property JsonObject focusedWindow: JsonObject {
                property JsonObject icon: JsonObject {
                    property bool enabled: true
                    property real size_factor: 1
                }
                property JsonObject title: JsonObject {
                    property bool enabled: true
                }
                property JsonObject font: JsonObject {
                    property string family
                    property real size_factor: 1.2
                    property int weight: 600
                }
            }

            property JsonObject power: JsonObject {
                property bool enabled: true
                property JsonObject font: JsonObject {
                    property string family
                    property real size_factor: 1.1
                    property int weight: 400
                }
            }

            property JsonObject time: JsonObject {
                property bool enabled: true
                property string format: "yyyy-dd-MM hh:mm:ss"
                property JsonObject font: JsonObject {
                    property string family
                    property real size_factor: 1.1
                    property int weight: 400
                }
            }

            property JsonObject workspaces: JsonObject {
                property bool enabled: true
                property JsonObject icon: JsonObject {
                    property real size_factor: 0.6
                    property real radius: 1
                }
            }
        }
    }
}
