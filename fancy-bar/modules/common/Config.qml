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
        blockLoading: true
        // For some reason, this is needed to read workspaces.maxCount from the
        // config.json.
        preload: false

        JsonAdapter {
            id: adapter

            // Global theme. Source of default and base values for all components.
            property JsonObject theme: JsonObject {
                property JsonObject colors: JsonObject {
                    property string text: "#999999"
                    property string textMuted: "#777777"
                    property string foreground: "#999999"
                    property string foreground2: "#777777"
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

            // Defines the widgets that should be shown in each section and their order.
            property JsonObject layout: JsonObject {
                property JsonObject left: JsonObject {
                    property list<string> widgets: ["workspaces", "focusedWindow"]
                    property bool separator: true
                    property int spacing: 6
                }
                property JsonObject center: JsonObject {
                    property list<string> widgets: []
                    property bool separator: true
                    property int spacing: 6
                }
                property JsonObject right: JsonObject {
                    property list<string> widgets: ["cpu", "ram", "network", "battery", "clock"]
                    property bool separator: true
                    property int spacing: 6
                }
            }

            property JsonObject bar: JsonObject {
                property string position: Types.positionToString(Types.Position.Top)
                property int size: 30
            }

            property JsonObject focusedWindow: JsonObject {
                property JsonObject icon: JsonObject {
                    property bool enabled: true
                    property real scale: 0.9
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

            property JsonObject cpu: JsonObject {
                property real scale: 1
                property real updateInterval: 1000  // Milliseconds
                property int numTopProcesses: 5
                property JsonObject icon: JsonObject {
                    property bool enabled: true
                    property real scale: 0.85
                    property string color: Config.data.theme.colors.foreground2
                }
                property JsonObject graph: JsonObject {
                    property bool enabled: true
                    property real history: 30 // Seconds
                    property string lineColor: Config.data.theme.colors.foreground
                    property string lowUsageColor: "#802D3154"   // Cool blue
                    property string highUsageColor: "#80FF4500"  // Bright orange/red
                }
            }

            property JsonObject ram: JsonObject {
                property real scale: 1
                property real updateInterval: 1000  // Milliseconds
                property string sizeUnit: "GiB"
                property int numTopProcesses: 5
                property JsonObject icon: JsonObject {
                    property bool enabled: true
                    property real scale: 1
                    property string color: Config.data.theme.colors.foreground2
                }
                property JsonObject colors: JsonObject {
                    property string used: "#2E86C1"           // Blue
                    property string shared: "#004880"         // Dark blue
                    property string buffersCached: "#7D3C98"  // Purple
                    property string free: "#666666"           // Gray
                }
                property JsonObject graph: JsonObject {
                    property bool enabled: true
                }
            }

            property JsonObject network: JsonObject {
                property real scale: 1
                // For up/down rates and graph updates
                property real rateUpdateInterval: 1000 // Milliseconds
                // For interface information (link speed, SSID, LAN IPs, etc.)
                property real infoUpdateInterval: 5 // Seconds
                // For external information (WAN IP)
                property real externalUpdateInterval: 600 // Seconds
                property JsonObject rates: JsonObject {
                    property bool enabled: true
                    property string baseUnit: "KiB"
                }
                property JsonObject graph: JsonObject {
                    property bool enabled: true
                    property real history: 30 // Seconds
                }
                property JsonObject icon: JsonObject {
                    property bool enabled: true
                    property real scale: 1
                    property string color: Config.data.theme.colors.foreground2
                }
                property JsonObject colors: JsonObject {
                    property string rx: "#1F77B4"  // Blue
                    property string tx: "#FF7F0E"  // Orange
                }
            }

            property JsonObject battery: JsonObject {
                property real scale: 1.5
                property int low: 20
                property int critical: 10
                property int suspend: 5
                property bool automaticSuspend: true
                property bool showPercentage: true
                property string orientation: Types.orientationToString(Types.Orientation.Horizontal)
            }

            property JsonObject clock: JsonObject {
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
                property int maxCount: 10
                property JsonObject icon: JsonObject {
                    property real scale: 0.6
                    property real radius: 1
                }
                property JsonObject colors: JsonObject {
                    property string active: "#000000"
                    property string inactive: "#333333"
                }
            }
        }
    }
}
