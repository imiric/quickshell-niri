import QtQuick
import QtQuick.Controls

// A menu that sets its width according to the size of its items, excluding MenuSeparator.
// Source: https://martin.rpdev.net/2018/03/13/qt-quick-controls-2-automatically-set-the-width-of-menus.html
Menu {
    implicitWidth: {
        let result = 0;
        let padding = 0;
        for (let i = 0; i < count; ++i) {
            let item = itemAt(i);
            if (item instanceof MenuItem && !(item instanceof MenuSeparator)) {
                result = Math.max(item.contentItem.implicitWidth, result);
                padding = Math.max(item.padding, padding);
            }
        }
        // Add a small margin factor for the padding.
        return result + padding * 3;
    }
}
