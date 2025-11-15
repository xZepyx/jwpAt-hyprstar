import Quickshell
import QtQuick
import QtQuick.Layouts
import "./bar_modules"

PanelWindow {
    anchors {
        top: true
        left: true
        right: true
    }

    color: "transparent"
    implicitHeight: 32

    Rectangle {
        anchors.fill: parent
        color: "transparent"

        Item {
            id: bar
            anchors.fill: parent

            // Left: Date/time
            DateTime {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
            }

            // Center: Workspaces (truly centered to the window)
            Workspaces {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
            }

            // (optional) Right side placeholder for future modules
            Item {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                width: 0    // or set later if you add stuff
                height: parent.height
            }
        }
    }
}
