import QtQuick
import QtQuick.Shapes

Item {
    id: root
    property real scale: 1
    property color color: "white"

    width: scale
    height: scale

    // Icon from Material Design Icons by Pictogrammers
    // https://github.com/Templarian/MaterialDesign/blob/master/LICENSE

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
            PathSvg { path: "M15 20a1 1 0 0 0-1-1h-1v-2h4a2 2 0 0 0 2-2V5a2 2 0 0 0-2-2H7a2 2 0 0 0-2 2v10a2 2 0 0 0 2 2h4v2h-1a1 1 0 0 0-1 1H2v2h7a1 1 0 0 0 1 1h4a1 1 0 0 0 1-1h7v-2zm-8-5V5h10v10zm3-9H8v8h2zm4 0h-3v8h2v-2h1a2 2 0 0 0 2-2V8a2 2 0 0 0-2-2m0 4h-1V8h1z" }
        }
    }
}
