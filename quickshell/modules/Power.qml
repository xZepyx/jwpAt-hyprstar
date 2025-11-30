// modules/Power.qml
import QtQuick
import Quickshell

Item {
    id: root
    implicitWidth: 28
    implicitHeight: 28

    property bool open: false

    // Folder for menu icons (used as defaults)
    property url menuIconDir: Qt.resolvedUrl("../assets/icons")

    // Power button icon
    property url powerIcon: menuIconDir + "/power.svg"

    // Menu icons (override from Bar.qml if you want)
    property url lockIcon:     menuIconDir + "/lock.svg"
    property url sleepIcon:    menuIconDir + "/sleep.svg"
    property url logoutIcon:   menuIconDir + "/logout.svg"
    property url rebootIcon:   menuIconDir + "/reboot.svg"
    property url shutdownIcon: menuIconDir + "/shutdown.svg"

    // Commands
    property var lockCommand:     ["loginctl", "lock-session"]     // or ["hyprlock"]
    property var sleepCommand:    ["systemctl", "suspend"]
    property var logoutCommand:   ["hyprctl", "dispatch", "exit"]  // or ["wlogout"]
    property var rebootCommand:   ["systemctl", "reboot"]
    property var shutdownCommand: ["systemctl", "poweroff"]

    // Theme
    property color bg: "#313244"
    property int radius: 14

    // Hover/click animation
    scale: area.pressed ? 0.985 : (area.containsMouse ? 1.08 : 1.0)
    Behavior on scale { NumberAnimation { duration: 140; easing.type: Easing.OutCubic } }

    Rectangle {
        id: btn
        anchors.fill: parent
        radius: root.radius
        color: area.pressed ? root.bgPressed : (area.containsMouse ? root.bgHover : root.bg)

        Image {
            anchors.centerIn: parent
            width: 18
            height: 18
            source: root.powerIcon
            fillMode: Image.PreserveAspectFit
            smooth: true
            mipmap: true
            sourceSize.width: 64
            sourceSize.height: 64
        }

        MouseArea {
            id: area
            anchors.fill: parent
            hoverEnabled: true
            onClicked: {
                root.open = !root.open
                if (root.open) Qt.callLater(menu.updatePos)
            }
        }
    }

    PowerMenu {
        id: menu
        open: root.open
        anchorItem: btn

        // forward icons
        lockIcon: root.lockIcon
        sleepIcon: root.sleepIcon
        logoutIcon: root.logoutIcon
        rebootIcon: root.rebootIcon
        shutdownIcon: root.shutdownIcon

        // forward commands
        lockCommand: root.lockCommand
        sleepCommand: root.sleepCommand
        logoutCommand: root.logoutCommand
        rebootCommand: root.rebootCommand
        shutdownCommand: root.shutdownCommand

        onRequestClose: root.open = false
    }
}
