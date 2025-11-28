// modules/Panel.qml
pragma Singleton
pragma ComponentBehavior: Bound
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import qs.services
import qs.modules
import qs.modules.controlpanel

Singleton {
    id: controller

    property bool open: false
    property bool closing: false

    function toggle()     { controller.open ? controller.closePanel() : controller.openPanel() }
    function openPanel()  { controller.closing = false; controller.open = true }
    function closePanel() { controller.closing = true; controller.open = false }

    // ---- BACKDROP (click to close) ----
    LazyLoader {
        id: backdropLoader
        activeAsync: controller.open || controller.closing

        PanelWindow {
            id: backdrop
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

    // ---- MAIN PANEL WINDOW ----
    LazyLoader {
        id: panelLoader
        activeAsync: controller.open || controller.closing

        PanelWindow {
            id: panel
            visible: true
            color: "transparent"
            exclusiveZone: 0

            width: 360
            height: 520

            anchors { top: true; right: true }

            // slide positions
            property int barHeight: 36
            property int gapUnderBar: 20
            property int shownTop: 6
            property int hiddenTop: shownTop - height - 20

            margins { top: hiddenTop; right: 6 }

            Behavior on margins.top {
                NumberAnimation {
                    duration: 220
                    easing.type: Easing.Out
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
                    if (!controller.open)
                        panel.margins.top = panel.hiddenTop
                }
            }

            // ---- CONTENT ----
            Rectangle {
                id: container
                anchors.fill: parent
                radius: 16
                color: "#181825"

                ColumnLayout {
                    id: mainLayout
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 12

                    // --- Top Section ---
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 12

                        ProfilePicture {}

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2
                            Layout.alignment: Qt.AlignVCenter

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
                                    text: SystemDetails.uptime   // your service uses uptime -p already
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

                    Rectangle {
                        Layout.fillWidth: true
                        height: 1
                        radius: 1
                        color: "#313244"
                        opacity: 0.9
                    }

                    // --- Your panel content goes here ---

                    GridLayout {
                    id: middleGrid
                    Layout.fillWidth: true
                    columns: 2
                    columnSpacing: Appearance.margin.large
                    rowSpacing: Appearance.margin.large

                    // Make all items stretch equally
                    Layout.preferredWidth: parent.width

                    Network {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 60
                        onActivate: function() { console.log("network clicked") }
                    }
                    Bluetooth {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 60
                        onActivate: function() { console.log("bluetooth clicked") }
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

                Rectangle {
                        Layout.fillWidth: true
                        height: 1
                        radius: 1
                        color: "#313244"
                        opacity: 0.9
                }

                Volume {
                        Layout.fillWidth: true
                }

                Brightness {
                        Layout.fillWidth: true
                }

                Item { Layout.fillHeight: true }
                }
            }
        }
    }

    function init() {}
}
