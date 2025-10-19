import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import "./modules/bar/"
import "./modules/common/"
import "./services/"

ShellRoot{
    LazyLoader{
        active: true
        component: Bar{
            position: Types.stringToPosition(Config.data.bar.position)
            size: Config.data.bar.size
            color: Config.data.theme.color.background
        }
    }
}
