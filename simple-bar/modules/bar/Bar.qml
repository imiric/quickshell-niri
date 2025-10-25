import QtQuick
import QtQuick.Layouts
import Quickshell

PanelWindow {
    id: bar
    function spawn(cmd) {
        try {
            if (typeof Quickshell !== 'undefined' && typeof Quickshell.execDetached === 'function') {
                // Use a shell to interpret the string command when necessary.
                Quickshell.execDetached(["sh", "-c", cmd]);
                return true;
            }
            // Fallback: attempt niri.spawn if provided by the compositor integration.
            if (typeof niri !== 'undefined' && typeof niri.spawn === 'function') {
                niri.spawn(cmd);
                return true;
            }
        } catch (e) {
            // ignore
        }
        return false;
    }
    anchors {
        top: true
        left: true
        right: true
    }
    implicitHeight: 30
    color: "transparent"

    Rectangle {
        anchors.fill: parent
        color: "#222222"
        bottomLeftRadius: 0
        bottomRightRadius: 0

        // left
        RowLayout {
            anchors {
                left: parent.left
                leftMargin: 25
            }
            spacing: 10
            Loader { active: true; sourceComponent: Workspaces {} }
            // Launchers: rely on Bar.spawn() -> Quickshell.execDetached to start commands detached.
            Loader { active: true; sourceComponent: LauncherButton { icon: "󰖟"; exec: "/usr/bin/helium-browser"; matchAppId: "helium"; spawner: bar } }
            Loader { active: true; sourceComponent: LauncherButton { icon: ""; exec: "/usr/bin/alacritty"; matchAppId: "alacritty"; spawner: bar } }
            Loader { active: true; sourceComponent: LauncherButton { icon: ""; exec: "/usr/bin/dolphin"; matchAppId: "dolphin"; spawner: bar } }
            Loader { active: true; sourceComponent: LauncherButton { icon: "󱩽"; exec: "/usr/bin/gedit"; matchAppId: "gedit"; spawner: bar } }
        }
        // center
        RowLayout {
            anchors {
                horizontalCenter: parent.horizontalCenter
                verticalCenter: parent.verticalCenter
            }

            Text {
                text: (typeof niri !== 'undefined' && typeof niri.focusedWindowTitle === 'string') ? niri.focusedWindowTitle : ""
                font.family: "Barlow Medium"
                font.pixelSize: 16
                color: "#999999"
            }
        }
        // right
        RowLayout {
            anchors {
                verticalCenter: parent.verticalCenter
                right: parent.right
                rightMargin: 25
            }
            spacing: 20
            Loader { active: true; sourceComponent: Systray { window: bar } }
            Loader { active: true; sourceComponent: Volume {} }
            Loader { active: true; sourceComponent: Power {} }
            Loader { active: true; sourceComponent: Time {} }
        }
    }
}
