import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import qs.modules.common

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
                blurMultiplier: 1.5
                shadowColor: "#C0000000"
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
                spacing: 10
                Loader {
                    active: Config.data.battery.enabled
                    sourceComponent: Battery {
                        orientation: Types.stringToOrientation(Config.data.battery.orientation)
                    }
                }
                Loader {
                    active: Config.data.datetime.enabled
                    sourceComponent: DateTime {
                        size: Math.min(
                            root.size * Config.data.datetime.scale - root.size * 0.2,
                            root.size
                        )
                    }
                }
            }
        }
    }
}
