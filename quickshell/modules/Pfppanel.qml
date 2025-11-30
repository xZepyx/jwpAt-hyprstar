import QtQuick
import QtQuick.Layouts
import Quickshell.Widgets
import qs.services as Services
import qs.modules as Modules

Rectangle {
    id: root
    height: 28
    radius: height / 2
    color: "#313244"
    border.width: 1
    border.color: "#313244"
    antialiasing: true

    // tighter padding for a 28px pill
    implicitWidth: row.implicitWidth + 12

    property bool hovered: false
    property bool pressed: false

    scale: pressed ? 0.96 : (hovered ? 1.02 : 1.0)
    Behavior on scale { NumberAnimation { duration: 120; easing.type: Easing.OutCubic } }

    function wifiIcon(connected, strength) {
        if (!connected) return "󰤮"
        if (strength >= 75) return "󰤨"
        if (strength >= 50) return "󰤥"
        if (strength >= 25) return "󰤢"
        return "󰤟"
    }

    RowLayout {
        id: row
        anchors.fill: parent
        anchors.margins: 0
        spacing: 2

        Rectangle {
            id: avatarBorder
            width: 28
            height: 28
            radius: width / 2
            color: "transparent"
            antialiasing: true
            Layout.alignment: Qt.AlignVCenter

            ClippingRectangle {
                anchors.fill: parent
                anchors.margins: 2
                radius: width / 2
                antialiasing: true
                layer.enabled: true
                layer.smooth: true

                Image {
                    anchors.fill: parent
                    source: Qt.resolvedUrl("../assets/pfp.jpg")
                    fillMode: Image.PreserveAspectCrop
                    smooth: true
                    mipmap: true
                }
            }
        }

        Text {
            text: wifiIcon(Services.Network.connected, Services.Network.signalStrength)
            font.family: "Hack Nerd Font"
            font.pixelSize: 14
            color: "#cdd6f4"
            opacity: Services.Network.connected ? 1.0 : 0.75
            Layout.alignment: Qt.AlignVCenter
        }

        Text {
            text: ""
            font.family: "Hack Nerd Font"
            font.pixelSize: 14
            color: "#cdd6f4"
            opacity: 0.95
            Layout.alignment: Qt.AlignVCenter
        }

        Text {
            text: "󰃠 "
            font.family: "Hack Nerd Font"
            font.pixelSize: 14
            color: "#cdd6f4"
            opacity: 0.95
            Layout.alignment: Qt.AlignVCenter
        }
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onEntered: root.hovered = true
        onExited: { root.hovered = false; root.pressed = false }
        onPressed: root.pressed = true
        onReleased: root.pressed = false
        onClicked: Modules.Panel.toggle()
    }
}
