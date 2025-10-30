import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland as Wayland

Item {
    id: root
    property alias icon: iconText.text
    property string exec: "" // command to run when not open
    property string matchAppId: "" // app id or wm-class to detect running windows
    property int iconSize: 16
    property var spawner: undefined // optional object (e.g. the bar) with a spawn/spawnCommand method
    // If true, never spawn a new instance when a matching window exists; instead just try to focus.
    // If focusing fails, do nothing (prevents duplicate instances).
    property bool singleInstance: true

    // Uniform cell sizing so icons align evenly regardless of glyph width
    property int padding: 1
    property int cellWidth: iconSize + padding * 2
    width: cellWidth
    height: Math.max(iconSize + padding * 2, iconText.implicitHeight + padding * 2)
    Layout.preferredWidth: width
    Layout.preferredHeight: height

    // Nerd-font icon text representing the app
    Text {
        id: iconText
        text: "?" // replace with nerd font char via `icon` property
        font.family: "Symbols Nerd Font"
        font.pixelSize: root.iconSize
        color: isOpen ? "#c4a912" : "#dac878"
        anchors.centerIn: parent
    }

    // Determine if a matching window is open by checking Wayland toplevels first,
    // then compositor-specific collections (niri) as a fallback.
    property bool isOpen: {
        try {
            var wins = listCandidates();
            for (var k=0;k<wins.length;k++) if (windowMatches(wins[k])) return true;
        } catch(e) {
            // model not available in this environment
        }
        return false;
    }

    function listCandidates() {
        var out = [];
        try {
            // Preferred: Wayland toplevels (works across many compositors)
            if (Wayland && Wayland.ToplevelManager && Wayland.ToplevelManager.toplevels && Wayland.ToplevelManager.toplevels.values) {
                var vals = Wayland.ToplevelManager.toplevels.values;
                for (var t=0;t<vals.length;t++) out.push(vals[t]);
                if (out.length > 0) return out;
            }
            // Fallback: niri-provided windows
            if (typeof niri !== 'undefined') {
                if (niri.windows) return niri.windows;
                if (niri.clients) return niri.clients;
                if (niri.workspaces) {
                    for (var i=0;i<niri.workspaces.length;i++) {
                        var w = niri.workspaces[i];
                        if (w && w.windows) {
                            for (var j=0;j<w.windows.length;j++) out.push(w.windows[j]);
                        }
                    }
                }
            }
        } catch (e) {
            // ignore
        }
        return out;
    }

    function windowMatches(win) {
        if (!win || !root.matchAppId) return false;
        // Wayland.Toplevel has appId + title; compositor-specific windows may expose various fields
        var ids = [win.appId, win.app_id, win.app, win.class, win.wmClass, win.appName, win.title];
        for (var m=0;m<ids.length;m++) {
            if (!ids[m]) continue;
            var v = ids[m].toString().toLowerCase();
            if (v.indexOf(root.matchAppId.toLowerCase()) !== -1) return true;
        }
        return false;
    }

    function findMatchingWindow() {
        var wins = listCandidates();
        for (var k=0;k<wins.length;k++) {
            if (windowMatches(wins[k])) return wins[k];
        }
        return null;
    }

    function tryFocus(win) {
        if (!win) return false;
        // Wayland toplevels support activate(); try that first.
        try {
            if (typeof win.activate === 'function') { win.activate(); return true; }
        } catch(e) { /* ignore and try compositor-specific */ }
        if (typeof niri === 'undefined') return false;
        try {
            if (typeof niri.focusWindowById === 'function' && win.id !== undefined) {
                niri.focusWindowById(win.id);
                return true;
            }
            if (typeof niri.focusWindow === 'function' && win.id !== undefined) {
                niri.focusWindow(win.id);
                return true;
            }
            var wsId = (win.workspaceId !== undefined) ? win.workspaceId : (win.workspace_id !== undefined ? win.workspace_id : (win.workspace && win.workspace.id !== undefined ? win.workspace.id : undefined));
            if (typeof niri.focusWorkspaceById === 'function' && wsId !== undefined) {
                niri.focusWorkspaceById(win.workspaceId);
                return true;
            }
        } catch (e) {
            console.log("LauncherButton: tryFocus error:", e);
        }
        return false;
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        onClicked: function() {
            // If a match exists, prefer focusing over spawning. If singleInstance, never spawn when open.
            try {
                var existing = root.findMatchingWindow();
                if (existing) {
                    var focused = root.tryFocus(existing);
                    if (root.singleInstance) return; // do not spawn duplicates
                    if (focused) return; // already focused, no need to spawn
                }
            } catch(e) {
                if (root.singleInstance && root.isOpen) return;
            }

            // If not open or focus failed, spawn the configured command
            if (root.exec && root.exec.length > 0) {
                try {
                    // Prefer a provided spawner object (e.g. the bar) so we don't rely on environment globals
                    if (root.spawner && typeof root.spawner.spawn === 'function' && root.spawner.spawn(root.exec)) return;
                    if (typeof Quickshell !== 'undefined' && typeof Quickshell.execDetached === 'function') {
                        Quickshell.execDetached(["sh", "-c", root.exec]);
                        return;
                    } else if (typeof niri !== 'undefined' && typeof niri.spawn === 'function') {
                        niri.spawn(root.exec);
                        return;
                    } else {
                        // No spawn method available
                    }
                } catch(e) {
                    // ignore
                }
            }
        }
    }
}
