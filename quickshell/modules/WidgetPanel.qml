// modules/WidgetPanel.qml
import Quickshell
import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import qs.modules.datetimepanel

PanelWindow {
    id: panel
    visible: false
    color: "transparent"
    exclusiveZone: 0

    // pages: 0 = Dashboard, 1 = Wallpapers
    property int pageIndex: 0

    function clamp01(v) { return Math.max(0, Math.min(1, v)) }
    function lerp(a, b, t) { return a + (b - a) * t }

    // --- shadow (small + clean corners) ---
    property int shadowPad: 10
    property real shadowOpacity: 0.28
    property real shadowBlur: 0.55
    property int shadowOffsetY: 6

    // size (PanelWindow prefers implicit sizes)
    property int contentW: 600
    property int contentH: 350
    implicitWidth: contentW + shadowPad * 2
    implicitHeight: contentH + shadowPad * 2

    anchors { top: true; left: true }
    margins { top: 6 - shadowPad; left: 6 - shadowPad }

    // ---- CONTENT (shadow outside, clip inside) ----
    Item {
        id: wrap
        anchors.fill: parent
        anchors.margins: panel.shadowPad

        Rectangle {
            anchors.fill: parent
            radius: 16
            antialiasing: true
            color: "#181825"

            layer.enabled: true
            layer.effect: MultiEffect {
                shadowEnabled: true
                shadowOpacity: panel.shadowOpacity
                shadowVerticalOffset: panel.shadowOffsetY
                shadowBlur: panel.shadowBlur
            }
        }

        Rectangle {
            id: clipCard
            anchors.fill: parent
            radius: 16
            color: "transparent"
            clip: true
            antialiasing: true

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 12
                spacing: 12

                // =========================
                // TOP MENU (spacers + underline tracks slide)
                // =========================
                Item {
                    id: topMenu
                    Layout.fillWidth: true
                    Layout.preferredHeight: 36

                    // using RowLayout + spacers to center each label in its half
                    RowLayout {
                        id: tabsRow
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: parent.top
                        height: parent.height - 2
                        spacing: 0

                        // ---- LEFT HALF ----
                        Item { Layout.fillWidth: true } // spacer (pushes toward half-center)

                        Item {
                            id: tabDashboard
                            Layout.preferredWidth: dashLabel.implicitWidth
                            Layout.preferredHeight: parent.height
                            readonly property real labelW: dashLabel.implicitWidth
                            readonly property real centerX: x + width / 2

                            Text {
                                id: dashLabel
                                anchors.centerIn: parent
                                text: "Dashboard"
                                color: panel.pageIndex === 0 ? "#f1f5ff" : "#cdd6f4"
                                opacity: panel.pageIndex === 0 ? 1.0 : 0.75
                                font.pixelSize: 13
                                font.weight: panel.pageIndex === 0 ? 700 : 600
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: panel.pageIndex = 0
                            }
                        }

                        Item { Layout.fillWidth: true } // spacer (finishes left half)

                        // ---- RIGHT HALF ----
                        Item { Layout.fillWidth: true } // spacer (pushes toward half-center)

                        Item {
                            id: tabWallpapers
                            Layout.preferredWidth: wallLabel.implicitWidth
                            Layout.preferredHeight: parent.height
                            readonly property real labelW: wallLabel.implicitWidth
                            readonly property real centerX: x + width / 2

                            Text {
                                id: wallLabel
                                anchors.centerIn: parent
                                text: "Wallpapers"
                                color: panel.pageIndex === 1 ? "#f1f5ff" : "#cdd6f4"
                                opacity: panel.pageIndex === 1 ? 1.0 : 0.75
                                font.pixelSize: 13
                                font.weight: panel.pageIndex === 1 ? 700 : 600
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: panel.pageIndex = 1
                            }
                        }

                        Item { Layout.fillWidth: true } // spacer (finishes right half)
                    }

                    Rectangle {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                        height: 1
                        color: "#313244"
                        opacity: 0.7
                    }

                    // Underline follows the pageRow slide (no Behavior on x/width)
                    Rectangle {
                        id: indicator
                        height: 2
                        radius: 2
                        color: "#b4befe"
                        y: topMenu.height - 2

                        readonly property real t: {
                            const w = Math.max(1, pageViewport.width)
                            return panel.clamp01((-pageRow.x) / w)
                        }

                        readonly property real dashCX: tabDashboard.centerX
                        readonly property real wallCX: tabWallpapers.centerX

                        width: Math.max(34, panel.lerp(tabDashboard.labelW + 10, tabWallpapers.labelW + 10, t))
                        x: panel.lerp(dashCX, wallCX, t) - width / 2
                    }
                }

                // =========================
                // PAGES (slide)
                // =========================
                Item {
                    id: pageViewport
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true

                    Row {
                        id: pageRow
                        width: pageViewport.width * 2
                        height: pageViewport.height
                        spacing: 0

                        x: -panel.pageIndex * pageViewport.width
                        Behavior on x { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }

                        // -------- Page 0: Dashboard --------
                        Item {
                            width: pageViewport.width
                            height: pageViewport.height

                            RowLayout {
                                anchors.fill: parent
                                spacing: 12

                                ColumnLayout {
                                    Layout.preferredWidth: 280
                                    Layout.minimumWidth: 280
                                    Layout.maximumWidth: 280
                                    Layout.fillHeight: true

                                    Item {
                                        Layout.fillWidth: true
                                        Layout.fillHeight: true
                                        clip: true
                                        Calendar { anchors.fill: parent }
                                    }
                                }

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    Layout.minimumWidth: 180
                                    spacing: 12

                                    Item {
                                        Layout.fillWidth: true
                                        Layout.fillHeight: true
                                        Layout.minimumHeight: 90

                                        Weather {
                                            anchors.fill: parent
                                            iconDir: "../assets/weather"
                                            active: panel.visible && panel.pageIndex === 0
                                        }
                                    }

                                    Item {
                                        Layout.fillWidth: true
                                        Layout.fillHeight: true
                                        Layout.minimumHeight: 90

                                        Rectangle {
                                            anchors.fill: parent
                                            radius: 14
                                            color: "#1e1e2e"
                                            Text {
                                                anchors.centerIn: parent
                                                text: "Filler widget 2"
                                                color: "#cdd6f4"
                                                font.pixelSize: 14
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        // -------- Page 1: Wallpapers (placeholder) --------
                        Item {
                            width: pageViewport.width
                            height: pageViewport.height

                            Rectangle {
                                anchors.fill: parent
                                radius: 14
                                color: "#1e1e2e"
                                border.width: 1
                                border.color: "#313244"
                                antialiasing: true

                                Column {
                                    anchors.centerIn: parent
                                    spacing: 8

                                    Text {
                                        text: "Wallpapers"
                                        color: "#f1f5ff"
                                        font.pixelSize: 18
                                        font.weight: 700
                                    }
                                    Text {
                                        text: "Placeholder page."
                                        color: "#cdd6f4"
                                        font.pixelSize: 12
                                        opacity: 0.85
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
