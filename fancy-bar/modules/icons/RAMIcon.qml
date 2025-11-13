import QtQuick
import QtQuick.Shapes
import Quickshell

Item {
    id: root
    property real scale: 1
    property color color: "white"

    width: scale
    height: scale

    // Icon from Phosphor by Phosphor Icons
    // https://github.com/phosphor-icons/core/blob/main/LICENSE
    // Slightly modified to add an additional DRAM chip, and make the chips filled out.

    Shape {
        anchors.centerIn: parent
        width: root.width
        height: root.height
        preferredRendererType: Shape.CurveRenderer
        fillMode: Shape.PreserveAspectFit
        transformOrigin: Item.TopLeft

        ShapePath {
            fillColor: root.color
            strokeColor: "transparent"
            PathSvg { path: "M 232,56 H 24 C 15.163444,56 8,63.163444 8,72 v 128 c 0,4.41828 3.581722,8 8,8 4.418278,0 8,-3.58172 8,-8 v -16 h 16 v 16 c 0,4.41828 3.581722,8 8,8 4.418278,0 8,-3.58172 8,-8 v -16 h 16 v 16 c 0,4.41828 3.581722,8 8,8 4.418278,0 8,-3.58172 8,-8 v -16 h 16 v 16 c 0,4.41828 3.58172,8 8,8 4.41828,0 8,-3.58172 8,-8 v -16 h 16 v 16 c 0,4.41828 3.58172,8 8,8 4.41828,0 8,-3.58172 8,-8 v -16 h 16 v 16 c 0,4.41828 3.58172,8 8,8 4.41828,0 8,-3.58172 8,-8 v -16 h 16 v 16 c 0,4.41828 3.58172,8 8,8 4.41828,0 8,-3.58172 8,-8 v -16 h 16 v 16 c 0,4.41828 3.58172,8 8,8 4.41828,0 8,-3.58172 8,-8 V 72 c 0,-8.836556 -7.16344,-16 -16,-16 M 24,72 h 208 v 96 H 24 Z m 56,80 c 4.41828,0 8,-3.58172 8,-8 V 96 c 0,-4.418278 -3.58172,-8 -8,-8 H 48 c -4.418278,0 -8,3.581722 -8,8 v 48 c 0,4.41828 3.581722,8 8,8 z m 64,0 c 4.41828,0 8,-3.58172 8,-8 V 96 c 0,-4.418278 -3.58172,-8 -8,-8 h -32 c -4.41828,0 -8,3.581722 -8,8 v 48 c 0,4.41828 3.58172,8 8,8 z m 64,0 c 4.41828,0 8,-3.58172 8,-8 V 96 c 0,-4.418278 -3.58172,-8 -8,-8 h -32 c -4.41828,0 -8,3.581722 -8,8 v 48 c 0,4.41828 3.58172,8 8,8 z" }
        }
    }
}
