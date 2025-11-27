import QtQuick
import Quickshell.Widgets

// Outer border container
Rectangle {
    id: avatarBorder
    width: 32        // slightly larger than your image
    height: 32
    radius: width / 2
    color: "transparent"
    border.width: 3
    border.color: "#313244"   // your border color
    antialiasing: true

    // Clipped avatar image
    ClippingRectangle {
        id: avatar
        anchors.fill: parent
        anchors.margins: 2     // small padding so border is fully visible
        radius: width / 2
        antialiasing: true
        layer.enabled: true
        layer.smooth: true

        Image {
            anchors.fill: parent
            source: Qt.resolvedUrl("../assets/pfp.png")
            fillMode: Image.PreserveAspectCrop
            smooth: true
            mipmap: true
        }
    }
}
