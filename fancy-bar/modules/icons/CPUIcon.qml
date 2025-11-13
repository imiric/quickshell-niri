import QtQuick
import QtQuick.Shapes
import Quickshell

Item {
    id: root
    property real scale: 1
    property color color: "white"

    width: scale
    height: scale

    // Icon from HeroIcons by Refactoring UI Inc
    // https://github.com/tailwindlabs/heroicons/blob/master/LICENSE

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
            PathSvg { path: "M14 6H6v8h8z" }
        }

        ShapePath {
            fillColor: root.color
            strokeColor: "transparent"
            PathSvg { path: "M9.25 3V1.75a.75.75 0 0 1 1.5 0V3h1.5V1.75a.75.75 0 0 1 1.5 0V3h.5A2.75 2.75 0 0 1 17 5.75v.5h1.25a.75.75 0 0 1 0 1.5H17v1.5h1.25a.75.75 0 0 1 0 1.5H17v1.5h1.25a.75.75 0 0 1 0 1.5H17v.5A2.75 2.75 0 0 1 14.25 17h-.5v1.25a.75.75 0 0 1-1.5 0V17h-1.5v1.25a.75.75 0 0 1-1.5 0V17h-1.5v1.25a.75.75 0 0 1-1.5 0V17h-.5A2.75 2.75 0 0 1 3 14.25v-.5H1.75a.75.75 0 0 1 0-1.5H3v-1.5H1.75a.75.75 0 0 1 0-1.5H3v-1.5H1.75a.75.75 0 0 1 0-1.5H3v-.5A2.75 2.75 0 0 1 5.75 3h.5V1.75a.75.75 0 0 1 1.5 0V3zM4.5 5.75c0-.69.56-1.25 1.25-1.25h8.5c.69 0 1.25.56 1.25 1.25v8.5c0 .69-.56 1.25-1.25 1.25h-8.5c-.69 0-1.25-.56-1.25-1.25z" }
        }
    }
}
