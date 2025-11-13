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
            PathSvg { path: "M7 15h2v3h2v-3h2v3h2v-3h2v3h2V9h-4V6H9v3H5v9h2zM4.38 3h15.25A2.37 2.37 0 0 1 22 5.38v14.25A2.37 2.37 0 0 1 19.63 22H4.38A2.37 2.37 0 0 1 2 19.63V5.38C2 4.06 3.06 3 4.38 3" }
        }
    }
}
