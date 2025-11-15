import Quickshell
import Quickshell.Hyprland
import QtQuick

Item {
    id: root
    property int maxWorkspaces: 5

    // Sizes
    property int activeSize: 16
    property int inactiveSize: 12
    property int unopenedSize: 10

    height: bg.implicitHeight
    width: bg.implicitWidth

    // --- Background ---
    Rectangle {
        id: bg
        color: "#313244"
        radius: 14
        anchors.centerIn: parent

        implicitWidth: row.implicitWidth + 16
        implicitHeight: row.implicitHeight + 9

        Row {
            id: row
            spacing: 4
            anchors.centerIn: parent

            Repeater {
                model: root.maxWorkspaces

                Item {
                    id: wsItem
                    width: root.activeSize
                    height: root.activeSize

                    property int wid: index + 1

                    // Workspace object (null if unopened)
                    property var workspaceObj: {
                        for (let w of Hyprland.workspaces) {
                            if (w.id === wid) return w;
                        }
                        return null;
                    }

                    // Focused workspace
                    property bool isFocused:
                        Hyprland.focusedWorkspace
                        && Hyprland.focusedWorkspace.id === wid

                    // Dot size logic
                    property int dotSize:
                        isFocused ? root.activeSize
                        : workspaceObj ? root.inactiveSize
                        : root.unopenedSize

                    // Hover logic
                    property bool hovering: false
                    property real hoverScale: (hovering && !isFocused) ? 1.2 : 1.0

                    // Final effective size
                    property int effectiveSize: Math.round(dotSize * hoverScale)

                    Rectangle {
                        id: pill
                        anchors.centerIn: parent
                        width: wsItem.effectiveSize
                        height: wsItem.effectiveSize
                        radius: width / 2

                        // Dot colors
                        color: wsItem.isFocused
                               ? "#cba6f7"
                               : wsItem.workspaceObj
                                 ? "transparent"
                                 : "#777"

                        // Border when workspace has windows
                        border.width: wsItem.workspaceObj ? 2 : 1
                        border.color: wsItem.isFocused ? "#777" : "#777"

                        // --- Remove old size Behaviors ---
                        Behavior on color { ColorAnimation { duration: 120 } }
                        Behavior on border.width { NumberAnimation { duration: 120 } }

                        // BOUNCE ANIMATION
                        SequentialAnimation {
                            id: bounceAnim
                            running: false
                            loops: 1

                            // Overshoot
                            NumberAnimation {
                                target: pill
                                property: "scale"
                                to: 1.35
                                duration: 120
                                easing.type: Easing.OutQuad
                            }

                            // Squash
                            NumberAnimation {
                                target: pill
                                property: "scale"
                                to: 0.90
                                duration: 120
                                easing.type: Easing.InOutQuad
                            }

                            // Settle to normal
                            NumberAnimation {
                                target: pill
                                property: "scale"
                                to: 1.0
                                duration: 130
                                easing.type: Easing.OutBounce
                            }
                        }

                        // Keep pill circular as size changes
                        onWidthChanged: height = width
                    }

                    // Run bounce when focused workspace changes
                    Connections {
                        target: Hyprland
                        onFocusedWorkspaceChanged: {
                            if (wsItem.isFocused)
                                pill.scale = 1.0, bounceAnim.start();
                        }
                    }

                    // Mouse
                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor

                        onEntered: wsItem.hovering = true
                        onExited: wsItem.hovering = false
                        onClicked: Hyprland.dispatch("workspace " + wsItem.wid)
                    }
                }
            }
        }
    }
}
