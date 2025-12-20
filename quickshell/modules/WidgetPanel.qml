// modules/WidgetPanel.qml
import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell
import Quickshell.Hyprland
import "datetimepanel" as DateTimePanel

PopupWindow {
    id: pop

    property bool open: false
    property Item anchorItem: null
    property int gap: 13
    signal requestClose()

    visible: (open && anchorItem !== null) || closing
    color: "transparent"

    property color panelBg: "#181825"
    property int panelRadius: 14
    property int shadowPad: 10
    property real shadowOpacity: 0.28
    property real shadowBlur: 0.55
    property int shadowOffsetY: 9

    property real animY: 0
    property real animScale: 1
    property real animOpacity: 1
    property bool closing: false

    property bool remindersExpanded: false
    property bool weatherExpanded: false

    onVisibleChanged: {
        if (visible && open) {
            playOpenAnim()
            remindersExpanded = false
            weatherExpanded = false
        }
    }

    onRemindersExpandedChanged: if (remindersExpanded) weatherExpanded = false
    onWeatherExpandedChanged: if (weatherExpanded) remindersExpanded = false

    function playOpenAnim() {
        closing = false
        animY = -14
        animScale = 0.975
        animOpacity = 0
        openAnim.restart()
    }

    function playCloseAnim() {
        if (closing) return
        closing = true
        focusGrab.active = false
        requestClose()
        closeAnim.restart()
    }

    function updatePos() {}

    onOpenChanged: {
        if (!open && visible && !closing) playCloseAnim()
    }

    LazyLoader {
        id: backdropLoader
        activeAsync: pop.visible

        PanelWindow {
            color: "transparent"
            visible: true
            exclusiveZone: -1
            anchors { top: true; bottom: true; left: true; right: true }

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.AllButtons
                hoverEnabled: true
                onPressed: pop.playCloseAnim()
            }
        }
    }

    HyprlandFocusGrab {
        id: focusGrab
        windows: [ pop ]
        active: pop.visible && !pop.closing
        onCleared: pop.playCloseAnim()
    }

    Item {
        anchors.fill: parent
        focus: true
        Keys.onEscapePressed: pop.playCloseAnim()
    }

    ParallelAnimation {
        id: openAnim
        SequentialAnimation {
            NumberAnimation { target: pop; property: "animY"; from: -14; to: 3; duration: 140; easing.type: Easing.OutCubic }
            NumberAnimation { target: pop; property: "animY"; from: 3; to: 0; duration: 170; easing.type: Easing.OutBack; easing.overshoot: 1.35 }
        }
        SequentialAnimation {
            NumberAnimation { target: pop; property: "animScale"; from: 0.975; to: 1.03; duration: 140; easing.type: Easing.OutCubic }
            NumberAnimation { target: pop; property: "animScale"; from: 1.03; to: 1.0; duration: 190; easing.type: Easing.OutBack; easing.overshoot: 1.25 }
        }
        NumberAnimation { target: pop; property: "animOpacity"; from: 0; to: 1; duration: 160; easing.type: Easing.OutCubic }
    }

    ParallelAnimation {
        id: closeAnim
        SequentialAnimation {
            NumberAnimation { target: pop; property: "animY"; from: 0; to: 2; duration: 70; easing.type: Easing.OutCubic }
            NumberAnimation { target: pop; property: "animY"; from: 2; to: -10; duration: 140; easing.type: Easing.InCubic }
        }
        NumberAnimation { target: pop; property: "animScale"; from: 1.0; to: 0.98; duration: 170; easing.type: Easing.InCubic }
        NumberAnimation { target: pop; property: "animOpacity"; from: 1; to: 0; duration: 150; easing.type: Easing.InCubic }
        onStopped: pop.closing = false
    }

    anchor.item: anchorItem
    Connections {
        target: pop.anchor
        function onAnchoring() {
            if (!pop.anchorItem) return
            pop.anchor.rect.x = Math.round(pop.anchorItem.width / 2 - pop.width / 2)
            pop.anchor.rect.y = Math.round(pop.anchorItem.height + pop.gap - pop.shadowPad)
            pop.anchor.rect.width = 1
            pop.anchor.rect.height = 1
        }
    }

    width: 600 + pop.shadowPad * 2
    height: 300 + pop.shadowPad * 2

    Item {
        id: animWrap
        anchors.fill: parent
        anchors.margins: pop.shadowPad
        y: pop.animY
        scale: pop.animScale
        opacity: pop.animOpacity
        transformOrigin: Item.Top

        Rectangle {
            id: card
            anchors.fill: parent
            radius: pop.panelRadius
            color: pop.panelBg
            antialiasing: true

            layer.enabled: true
            layer.effect: MultiEffect {
                shadowEnabled: true
                shadowOpacity: pop.shadowOpacity
                shadowVerticalOffset: pop.shadowOffsetY
                shadowBlur: pop.shadowBlur
            }
        }

        Rectangle {
            anchors.fill: parent
            radius: pop.panelRadius
            color: "transparent"
            clip: true
            antialiasing: true

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.AllButtons
                hoverEnabled: true
                propagateComposedEvents: false
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 12
                spacing: 12

                Item {
                    id: dashboardPage
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    // Overlay for REMINDERS expansion
                    Item {
                        id: overlaySurface
                        anchors.fill: parent
                        visible: pop.remindersExpanded
                        z: 9999

                        Rectangle { anchors.fill: parent; color: "#000000"; opacity: 0 }

                        MouseArea {
                            anchors.fill: parent
                            onPressed: (m) => { m.accepted = true }
                            onClicked: (m) => { m.accepted = true }
                        }
                    }

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
                                opacity: pop.remindersExpanded ? 0.0 : 1.0
                                enabled: !pop.remindersExpanded
                                Behavior on opacity { NumberAnimation { duration: 140 } }

                                DateTimePanel.Calendar { anchors.fill: parent }
                            }
                        }

                        Item {
                            id: rightRegion
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            Layout.minimumWidth: 180

                            ColumnLayout {
                                anchors.fill: parent
                                spacing: 12

                                Item {
                                    id: weatherSlot
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    Layout.minimumHeight: 65
                                    opacity: pop.remindersExpanded ? 0.0 : 1.0
                                    enabled: !pop.remindersExpanded
                                    Behavior on opacity { NumberAnimation { duration: 140 } }
                                }

                                Item {
                                    id: remindersSlot
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    Layout.minimumHeight: 90
                                }
                            }
                        }
                    }

                    // Weather Host
                    Item {
                        id: weatherHost
                        z: 9500

                        Behavior on x { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }
                        Behavior on y { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }
                        Behavior on width { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }
                        Behavior on height { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }

                        DateTimePanel.Weather {
                            anchors.fill: parent
                            iconDir: "../assets/weather"

                            expanded: pop.weatherExpanded
                            onRequestExpand: pop.weatherExpanded = true
                            onRequestCollapse: pop.weatherExpanded = false

                            active: pop.visible && !pop.remindersExpanded
                        }
                    }

                    // Reminders Host
                    Item {
                        id: remindersHost
                        z: 10000

                        opacity: pop.weatherExpanded ? 0.0 : 1.0
                        enabled: !pop.weatherExpanded
                        Behavior on opacity { NumberAnimation { duration: 140 } }

                        Behavior on x { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }
                        Behavior on y { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }
                        Behavior on width { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }
                        Behavior on height { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }

                        DateTimePanel.Reminders {
                            anchors.fill: parent
                            expanded: pop.remindersExpanded
                            onRequestExpand: pop.remindersExpanded = true
                            onRequestCollapse: pop.remindersExpanded = false
                        }
                    }

                    StateGroup {
                        states: [
                            State {
                                name: "remindersNormal"
                                when: !pop.remindersExpanded
                                ParentChange { target: remindersHost; parent: remindersSlot }
                                PropertyChanges { target: remindersHost; x: 0; y: 0; width: remindersSlot.width; height: remindersSlot.height }
                            },
                            State {
                                name: "remindersExpanded"
                                when: pop.remindersExpanded
                                ParentChange { target: remindersHost; parent: dashboardPage }
                                PropertyChanges { target: remindersHost; x: 0; y: 0; width: dashboardPage.width; height: dashboardPage.height }
                            }
                        ]
                    }

                    StateGroup {
                        states: [
                            State {
                                name: "weatherNormal"
                                when: !pop.weatherExpanded
                                ParentChange { target: weatherHost; parent: weatherSlot }
                                PropertyChanges { target: weatherHost; x: 0; y: 0; width: weatherSlot.width; height: weatherSlot.height }
                            },
                            State {
                                name: "weatherExpanded"
                                when: pop.weatherExpanded
                                ParentChange { target: weatherHost; parent: rightRegion }
                                PropertyChanges { target: weatherHost; x: 0; y: 0; width: rightRegion.width; height: rightRegion.height }
                            }
                        ]
                    }
                }
            }
        }
    }
}