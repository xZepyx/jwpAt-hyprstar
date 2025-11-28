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
    property string fallbackTitle: "Bluetooth"

    readonly property bool isConnected: Services.Bluetooth.connected
    readonly property bool isPowered: Services.Bluetooth.powered

    // palette (same as your Wi-Fi button)
    readonly property color cBg:        "#B4BEFE"
    readonly property color cBorder:    "#45475a"
    readonly property color cIcon:      "#1e1e2e"
    readonly property color cTitle:     "#1E1E2E"
    readonly property color cSubtitle:  "#313244"

    readonly property color dBg:        "#313244"
    readonly property color dBorder:    "#45475a"
    readonly property color dIcon:      "#CDD6F4"
    readonly property color dTitle:     "#CDD6F4"
    readonly property color dSubtitle:  "#A6ADC8"

    readonly property color bgColor:       isConnected ? cBg : dBg
    readonly property color borderColor:   isConnected ? cBorder : dBorder
    readonly property color iconColor:     isConnected ? cIcon : dIcon
    readonly property color titleColor:    isConnected ? cTitle : dTitle
    readonly property color subtitleColor: isConnected ? cSubtitle : dSubtitle

    function btIcon(powered, connected) {
        if (!powered) return "󰂯"      // off (swap if you want)
        if (connected) return "󰂯"     // connected (swap if you want)
        return "󰂯"                    // on
    }

    function subtitleText() {
        if (!isPowered) return "Off"
        return isConnected ? "Connected" : "On"
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
                text: btIcon(isPowered, isConnected)
                color: iconColor
                font.pixelSize: 18
                font.family: "Hack Nerd Font"
                opacity: isPowered ? 1.0 : 0.8
                Layout.alignment: Qt.AlignVCenter
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: -3
                Layout.alignment: Qt.AlignVCenter

                Text {
                    Layout.fillWidth: true
                    text: isConnected ? Services.Bluetooth.deviceName : root.fallbackTitle
                    color: titleColor
                    font.pixelSize: 14
                    font.weight: 600
                    elide: Text.ElideRight
                }

                Text {
                    Layout.fillWidth: true
                    text: subtitleText()
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
