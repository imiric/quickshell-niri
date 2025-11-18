import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.modules.common

RowLayout {
    id: root

    required property string section
    property var widgetComponents
    spacing: Config.data.layout[section]?.spacing || 0

    readonly property var widgetModel: {
        let model = [];
        let hasPreviousWidget = false;
        const widgets = Config.data.layout[section]?.widgets || [];
        const useSeparator = Config.data.layout[section]?.separator || false;

        for (let i = 0; i < widgets.length; i++) {
            const widget = widgetComponents[widgets[i]];
            if (!widget) {
                console.error(`invalid widget: ${widgets[i]}`);
                continue;
            }

            if (useSeparator && hasPreviousWidget) {
                model.push(widgetComponents["separator"]);
            }
            model.push(widget);
            hasPreviousWidget = true;
        }

        return model;
    }

    Repeater {
        model: root.widgetModel
        delegate: Loader {
            active: true
            sourceComponent: modelData
        }
    }
}
