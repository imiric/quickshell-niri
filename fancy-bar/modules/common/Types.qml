pragma Singleton
import QtQuick

QtObject {
    enum Orientation {
        Horizontal,
        Vertical
    }

    enum Position {
        Top,
        Bottom
    }

    /**
     * I would prefer to use stdlib enum conversion functions:
     * https://doc.qt.io/qt-6/qtqml-typesystem-enumerations.html
     * But these aren't defined in Quickshell v0.2.1, for some reason, even
     * though it does use Qt 6.10...
     */
    function stringToOrientation(str) {
        const normalized = str.toLowerCase();
        switch (normalized) {
        case "horizontal":
            return Types.Orientation.Horizontal;
        case "vertical":
            return Types.Orientation.Vertical;
        default:
            console.error("Error: invalid Orientation value:", str)
            return -1;
        }
    }

    function orientationToString(value) {
        switch (value) {
        case Types.Orientation.Horizontal:
            return "horizontal"
        case Types.Orientation.Vertical:
            return "vertical"
        default:
            console.error("Error: invalid Orientation value:", value)
            return "";
        }
    }

    function stringToPosition(str) {
        const normalized = str.toLowerCase();
        switch (normalized) {
        case "top":
            return Types.Position.Top;
        case "bottom":
            return Types.Position.Bottom;
        default:
            console.error("Error: invalid Position value:", str)
            return -1;
        }
    }

    function positionToString(value) {
        switch (value) {
        case Types.Position.Top:
            return "top"
        case Types.Position.Bottom:
            return "bottom"
        default:
            console.error("Error: invalid Position value:", value)
            return "";
        }
    }
}
