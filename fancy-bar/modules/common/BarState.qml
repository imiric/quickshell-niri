pragma Singleton
import Quickshell
import Quickshell.Io

Singleton {
    readonly property var data: adapter
    readonly property var view: view

    FileView {
        id: view
        path: Quickshell.shellPath("state.json")
        watchChanges: true
        onFileChanged: reload()
        onAdapterUpdated: writeAdapter()
        blockLoading: true

        JsonAdapter {
            id: adapter

            property JsonObject network: JsonObject {
                property string activeInterface: ""
                property int type: -1
            }
        }
    }
}
