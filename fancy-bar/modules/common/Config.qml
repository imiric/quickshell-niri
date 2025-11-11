pragma Singleton
import Quickshell
import Quickshell.Io
import qs.modules.common

Singleton {
    property var data: adapter

    FileView {
        path: Quickshell.shellPath("config.json")
        watchChanges: true
        onFileChanged: reload()
        onAdapterUpdated: writeAdapter()

        JsonAdapter {
            id: adapter

            // Global theme. Source of default and base values for all components.
            property JsonObject theme: JsonObject {
                property JsonObject color: JsonObject {
                    property string active: "#000000"
                    property string inactive: "#333333"
                    property string text: "#999999"
                    property string textMuted: "#777777"
                    property string foreground: "#999999"
                    property string background: "#222222"
                    property string background2: "#666666"
                    property string ok: "#1A7F39"
                    property string error: "#E5002E"
                    property string warning: "#E5BF00"
                }
                // Proportional font
                property JsonObject font: JsonObject {
                    property string family: "Sans"
                    // Size in pixels of all proportional fonts. The actual size
                    // of fonts in individual components will be proportional to
                    // this value.
                    property real size: 14
                }
                // Monospace font
                property JsonObject fontMono: JsonObject {
                    property string family: "Monospace"
                    // Size in pixels of all monospace fonts. The actual size of
                    // fonts in individual components will be proportional to
                    // this value.
                    property real size: 14
                }
                property JsonObject widget: JsonObject {
                    // Size in pixels of all widgets. The actual size of
                    // individual widgets will be proportial to this value.
                    property real size: 24
                }
            }

            property JsonObject bar: JsonObject {
                property string position: Types.positionToString(Types.Position.Top)
                property int size: 30
            }

            property JsonObject focusedWindow: JsonObject {
                property bool enabled: true
                property JsonObject icon: JsonObject {
                    property bool enabled: true
                    property real scale: 1
                }
                property JsonObject title: JsonObject {
                    property bool enabled: true
                }
                property JsonObject font: JsonObject {
                    property string family
                    property real scale: 1.2
                    property int weight: 600
                }
            }

            property JsonObject battery: JsonObject {
                property bool enabled: true
                property real scale: 1.5
                property int low: 20
                property int critical: 10
                property int suspend: 5
                property bool automaticSuspend: true
                property bool showPercentage: true
                property string orientation: Types.orientationToString(Types.Orientation.Horizontal)
            }

            property JsonObject datetime: JsonObject {
                property bool enabled: true
                property real scale: 1
                property JsonObject time: JsonObject {
                    property bool enabled: true
                    property string format: "hh:mm"
                }
                property JsonObject date: JsonObject {
                    property bool enabled: true
                    property string format: "yyyy-MM-dd"
                }
                property JsonObject font: JsonObject {
                    property string family
                    property real scale: 1.1
                    property int weight: 400
                }
            }

            property JsonObject workspaces: JsonObject {
                property bool enabled: true
                property JsonObject icon: JsonObject {
                    property real scale: 0.6
                    property real radius: 1
                }
            }
        }
    }
}
