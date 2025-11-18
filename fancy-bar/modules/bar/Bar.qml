import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import qs.modules.common
import qs.modules.common.utils
import qs.modules.icons

Item {
    id: root
    property int position: Types.Position.Top
    property string color: "gray"
    property int size: 30

    WlrLayershell {
        id: barShadow
        implicitHeight: bar.height + 100
        color: "transparent"
        layer: WlrLayer.Bottom
        exclusiveZone: 0
        anchors: bar.anchors

        Rectangle {
            color: barContent.color
            anchors {
                top: root.position === Types.Position.Top ? parent.top : undefined
                bottom: root.position === Types.Position.Bottom ? parent.bottom : undefined
            }
            height: barContent.height
            // The +40 here and the -20 shadowHorizontalOffset are to have the
            // shadow extend all the way along the edge. Otherwise it would be
            // slightly cut off at the left and right corners.
            width: parent.width + 40

            layer.enabled: true
            layer.effect: MultiEffect {
                shadowEnabled: true
                // The vertical offset makes the shadow slightly more prominent
                shadowVerticalOffset: root.position === Types.Position.Top ? 5 : -5
                shadowHorizontalOffset: -20
                shadowBlur: 1
                blurMultiplier: 1
                shadowColor: "#D0000000"
            }
        }
    }

    PanelWindow {
        id: bar
        implicitHeight: root.size
        color: "transparent"
        anchors {
            top: root.position === Types.Position.Top
            bottom: root.position === Types.Position.Bottom
            left: true
            right: true
        }

        Rectangle {
            id: barContent
            anchors.fill: parent
            color: root.color

            RowLayout {
                id: leftLayout
                anchors {
                    left: parent.left
                    leftMargin: 25
                }
                Loader { active: Config.data.workspaces.enabled; sourceComponent: Workspaces {} }
            }

            RowLayout {
                id: centerLayout
                anchors {
                    left: leftLayout.right
                    leftMargin: 5
                    verticalCenter: parent.verticalCenter
                }
                Loader { active: Config.data.focusedWindow.enabled; sourceComponent: FocusedWindow {} }
            }

            RowLayout {
                id: rightLayout
                anchors {
                    verticalCenter: parent.verticalCenter
                    right: parent.right
                    rightMargin: 25
                }
                spacing: 6

                Component {
                    id: separatorComponent
                    SeparatorIcon {
                        color: ColorUtils.transparentize(Config.data.theme.color.foreground2, 0.5)
                        angle: 90
                        length: bar.height - bar.height * 0.4
                        strokeSize: 4
                        spacing: 1.5
                        lineType: "dotted"
                        dashLength: 1
                        edgeRadius: 4
                        Layout.alignment: Qt.AlignVCenter
                    }
                }

                // Widget component definitions
                Component { id: cpuComponent; CPU {} }
                Component { id: ramComponent; RAM {} }
                Component { id: networkComponent; Network {} }
                Component {
                    id: batteryComponent
                    Battery {
                        orientation: Types.stringToOrientation(Config.data.battery.orientation)
                    }
                }
                Component {
                    id: clockComponent
                    Clock {
                        size: Math.min(
                            root.size * Config.data.clock.scale - root.size * 0.2,
                            root.size,
                        )
                    }
                }

                readonly property var componentMap: {
                    "cpu": cpuComponent,
                    "ram": ramComponent,
                    "network": networkComponent,
                    "battery": batteryComponent,
                    "clock": clockComponent,
                }

                readonly property var widgetModel: {
                    let model = [];
                    let hasPreviousWidget = false;
                    const enabledWidgets = Config.data.enabledWidgets.right;

                    for (let i = 0; i < enabledWidgets.length; i++) {
                        const widget = rightLayout.componentMap[enabledWidgets[i]];
                        if (!widget) {
                            console.error(`invalid widget: ${enabledWidgets[i]}`);
                            continue;
                        }

                        if (hasPreviousWidget) {
                            model.push(separatorComponent);
                        }
                        model.push(widget);
                        hasPreviousWidget = true;
                    }

                    return model;
                }

                // Dynamic layout generator
                Repeater {
                    model: rightLayout.widgetModel

                    delegate: Loader {
                        active: true
                        sourceComponent: modelData
                    }
                }
            }
        }
    }
}
