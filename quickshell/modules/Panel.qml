pragma Singleton
pragma ComponentBehavior: Bound

import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell
import Quickshell.Widgets
import qs.services
import qs.modules
import qs.modules.controlpanel

Singleton {
    id: controller

    property bool open: false
    property bool closing: false

    function toggle() { open ? closePanel() : openPanel() }
    function openPanel() { closing = false; open = true }
    function closePanel() { closing = true; open = false }

    // ===== BACKDROP =====
    LazyLoader {
        activeAsync: controller.open || controller.closing

        PanelWindow {
            color: "transparent"
            visible: true
            exclusiveZone: -1
            anchors { top: true; bottom: true; left: true; right: true }

            MouseArea {
                anchors.fill: parent
                onClicked: controller.closePanel()
            }
        }
    }

    // ===== MAIN PANEL =====
    LazyLoader {
        activeAsync: controller.open || controller.closing

        PanelWindow {
            id: panel
            visible: true
            color: "transparent"
            exclusiveZone: 0

            // Layout
            property int contentW: 360
            property int contentH: 520
            property int shadowPad: 10
            property real shadowOpacity: 0.28
            property real shadowBlur: 0.55
            property int shadowOffsetY: 6

            width: contentW + shadowPad * 2
            height: contentH + shadowPad * 2
            anchors { top: true; right: true }

            // Slide animation positions
            property int shownTop: 6 - shadowPad
            property int hiddenTop: shownTop - height - 20

            margins { top: hiddenTop; right: 6 - shadowPad }

            Behavior on margins.top {
                NumberAnimation {
                    duration: 220
                    easing.type: Easing.OutCubic
                    onRunningChanged: {
                        if (!running && controller.closing && !controller.open)
                            controller.closing = false
                    }
                }
            }

            Component.onCompleted: margins.top = shownTop

            Connections {
                target: controller
                function onOpenChanged() {
                    if (!controller.open) panel.margins.top = panel.hiddenTop
                }
            }

            // ===== CONTENT =====
            Item {
                anchors.fill: parent
                anchors.margins: panel.shadowPad

                // Shadow + background
                Rectangle {
                    anchors.fill: parent
                    radius: 16
                    color: "#181825"
                    layer.enabled: true
                    layer.effect: MultiEffect {
                        shadowEnabled: true
                        shadowOpacity: panel.shadowOpacity
                        shadowVerticalOffset: panel.shadowOffsetY
                        shadowBlur: panel.shadowBlur
                    }
                }

                // Content clip
                Rectangle {
                    anchors.fill: parent
                    radius: 16
                    color: "transparent"
                    clip: true

                    // Prevent clicks from reaching backdrop
                    MouseArea {
                        anchors.fill: parent
                        acceptedButtons: Qt.AllButtons
                        onPressed: mouse.accepted = true
                    }

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 12

                        // ===== HEADER =====
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 12

                            ProfilePicture {}

                            ColumnLayout {
                                Layout.fillWidth: true
                                Layout.alignment: Qt.AlignVCenter
                                spacing: 2

                                Text {
                                    text: "hello, " + SystemDetails.username
                                    color: "#f5e0dc"
                                    font.pixelSize: 22
                                    font.weight: 600
                                    font.family: "Adwaita Sans"
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                }

                                RowLayout {
                                    spacing: 8

                                    Text {
                                        text: SystemDetails.osIcon
                                        color: "#cdd6f4"
                                        font.pixelSize: 18
                                    }

                                    Text {
                                        text: SystemDetails.uptime
                                        color: "#cdd6f4"
                                        opacity: 0.85
                                        font.pixelSize: 14
                                        elide: Text.ElideRight
                                        Layout.fillWidth: true
                                    }
                                }
                            }

                            Item { Layout.fillWidth: true }
                        }

                        // Separator
                        Rectangle {
                            Layout.fillWidth: true
                            height: 1
                            color: "#313244"
                            opacity: 0.9
                        }

                        // ===== QUICK TOGGLES =====
                        GridLayout {
                            Layout.fillWidth: true
                            columns: 2
                            columnSpacing: Appearance.margin.large
                            rowSpacing: Appearance.margin.large

                            Network {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 60
                                onActivate: console.log("network clicked")
                            }

                            Bluetooth {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 60
                                onActivate: console.log("bluetooth clicked")
                            }

                            Inhibitor {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 60
                            }

                            Dnd {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 60
                            }
                        }

                        // Separator
                        Rectangle {
                            Layout.fillWidth: true
                            height: 1
                            color: "#313244"
                            opacity: 0.9
                        }

                        // ===== SLIDERS =====
                        Volume { Layout.fillWidth: true }
                        Brightness { Layout.fillWidth: true }

                        Item { Layout.fillHeight: true }
                    }
                }
            }
        }
    }

    function init() {}
}