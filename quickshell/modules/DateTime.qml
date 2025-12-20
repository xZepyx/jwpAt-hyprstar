// modules/DateTime.qml
import QtQuick
import Quickshell

Rectangle {
    id: root
    height: 28
    radius: height / 2
    color: "#313244"
    border.width: 1
    border.color: "#313244"
    antialiasing: true
    implicitWidth: timeText.implicitWidth + 12

    property bool hovered: false
    property bool pressed: false
    property string currentTime: ""
    property bool open: false

    // your animation formula
    scale: pressed ? 0.985 : (hovered ? 1.03 : 1.0)
    Behavior on scale {
        NumberAnimation { duration: 90; easing.type: Easing.OutQuad }
    }

    Text {
        id: timeText
        anchors.centerIn: parent
        text: root.currentTime
        color: "#cdd6f4"
        font.family: "Adwaita Sans"
        font.pixelSize: 13
        font.weight: 600
    }

    function updateDateTime() {
        const d = new Date()
        currentTime = Qt.formatDateTime(d, "HH:mm • ddd, MM/dd")
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onEntered: root.hovered = true
        onExited: root.hovered = false
        onPressed: root.pressed = true
        onReleased: root.pressed = false
        onClicked: {
            root.open = !root.open
            if (root.open) Qt.callLater(panel.updatePos)
        }
    }

    Timer {
        interval: 1000
        repeat: true
        running: true
        triggeredOnStart: true
        onTriggered: root.updateDateTime()
    }

    WidgetPanel {
        id: panel
        open: root.open
        anchorItem: root
        onRequestClose: root.open = false
    }
}