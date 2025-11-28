import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import qs.services as Services

Item {
    id: root
    implicitHeight: 60
    Layout.fillWidth: true

    property var onActivate: function() {}

    // ---- palettes ----
    readonly property bool isConnected: Services.Network.connected

    // connected palette (your current vibe)
    readonly property color cBg:        "#B4BEFE"
    readonly property color cBorder:    "#45475a"
    readonly property color cIcon:      "#1e1e2e"
    readonly property color cTitle:     "#1E1E2E"
    readonly property color cSubtitle:  "#313244"

    // disconnected palette (dark + readable)
    readonly property color dBg:        "#313244"
    readonly property color dBorder:    "#45475a"
    readonly property color dIcon:      "#CDD6F4"
    readonly property color dTitle:     "#CDD6F4"
    readonly property color dSubtitle:  "#A6ADC8"

    // resolved colors
    readonly property color bgColor:       isConnected ? cBg : dBg
    readonly property color borderColor:   isConnected ? cBorder : dBorder
    readonly property color iconColor:     isConnected ? cIcon : dIcon
    readonly property color titleColor:    isConnected ? cTitle : dTitle
    readonly property color subtitleColor: isConnected ? cSubtitle : dSubtitle

    function wifiIcon(connected, strength) {
        if (!connected) return "󰤮"
        if (strength >= 75) return "󰤨"
        if (strength >= 50) return "󰤥"
        if (strength >= 25) return "󰤢"
        return "󰤟"
    }

    Rectangle {
        id: card
        anchors.fill: parent
        radius: 16

        color: bgColor
        border.width: 1
        border.color: borderColor

        property bool hovered: false
        property bool pressed: false
        scale: pressed ? 0.98 : (hovered ? 1.01 : 1.0)

        Behavior on scale { NumberAnimation { duration: 110; easing.type: Easing.OutCubic } }
        Behavior on color { ColorAnimation { duration: 120 } }
        Behavior on border.color { ColorAnimation { duration: 120 } }

        RowLayout {
            anchors.fill: parent
            anchors.margins: 12
            spacing: 10

            Text {
                text: wifiIcon(isConnected, Services.Network.signalStrength)
                color: iconColor
                font.pixelSize: 18
                font.family: "Hack Nerd Font"
                opacity: isConnected ? 1.0 : 0.9
                Layout.alignment: Qt.AlignVCenter
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: -3
                Layout.alignment: Qt.AlignVCenter

                Text {
                    Layout.fillWidth: true
                    text: Services.Network.connectedSsid
                    color: titleColor
                    font.pixelSize: 14
                    font.weight: 600
                    elide: Text.ElideRight
                }

                Text {
                    Layout.fillWidth: true
                    text: isConnected ? "Connected" : "Disconnected"
                    color: subtitleColor
                    opacity: 0.9
                    font.pixelSize: 12
                    elide: Text.ElideRight
                }
            }
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onEntered: card.hovered = true
            onExited: card.hovered = false
            onPressed: card.pressed = true
            onReleased: card.pressed = false
            onClicked: root.onActivate()
        }
    }
}
