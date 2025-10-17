pragma Singleton
import QtQuick

QtObject {
    enum Orientation {
        Horizontal,
        Vertical
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
}
