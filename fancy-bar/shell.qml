import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import "./modules/bar/"
import "./services/"

ShellRoot{
    LazyLoader{ active: true; component: Bar{} }
}
