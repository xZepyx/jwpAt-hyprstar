import Quickshell
import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import qs.modules

PanelWindow {
    id: topBar
    implicitHeight: 40
    color: "transparent"

    anchors { top: true; left: true; right: true }

    // LEFT
    RowLayout {
        id: leftCluster
        anchors.left: parent.left
        anchors.leftMargin: 6
        anchors.verticalCenter: parent.verticalCenter
        height: parent.height
        spacing: 6

        DateTime {
            Layout.alignment: Qt.AlignVCenter
        }

        Battery {
            Layout.alignment: Qt.AlignVCenter
        }
    }

    // CENTER (Workspaces truly centered)
    RowLayout {
        id: centerCluster
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        height: parent.height
        spacing: 6

        // side slot width = whichever side is wider
        readonly property real sideW: Math.max(leftContent.implicitWidth, rightContent.implicitWidth)

        // LEFT SLOT (same width as right slot)
        Item {
            id: leftSlot
            Layout.preferredWidth: centerCluster.sideW
            Layout.minimumWidth: centerCluster.sideW
            Layout.fillHeight: true
            Layout.alignment: Qt.AlignVCenter

            // pin actual left content to the RIGHT edge of the slot
            Row {
                id: leftContent
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                spacing: 6

                Memory {}
                Temperature {}

                Power {
                    powerIcon:    Qt.resolvedUrl("../assets/power_icons/power-1.svg")
                    lockIcon:     Qt.resolvedUrl("../assets/power_icons/lock.svg")
                    sleepIcon:    Qt.resolvedUrl("../assets/power_icons/moon.svg")
                    logoutIcon:   Qt.resolvedUrl("../assets/power_icons/log-out.svg")
                    rebootIcon:   Qt.resolvedUrl("../assets/power_icons/refresh-cw.svg")
                    shutdownIcon: Qt.resolvedUrl("../assets/power_icons/power.svg")
                }
            }
        }

        // TRUE CENTER
        Workspaces {
            Layout.alignment: Qt.AlignVCenter
        }

        // RIGHT SLOT (same width as left slot)
        Item {
            id: rightSlot
            Layout.preferredWidth: centerCluster.sideW
            Layout.minimumWidth: centerCluster.sideW
            Layout.fillHeight: true
            Layout.alignment: Qt.AlignVCenter

            // pin actual right content to the LEFT edge of the slot
            Row {
                id: rightContent
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                spacing: 6

                Mediaplayer { id: media }
            }
        }
    }

    // RIGHT
    RowLayout {
        id: rightCluster
        anchors.right: parent.right
        anchors.rightMargin: 6
        anchors.verticalCenter: parent.verticalCenter
        height: parent.height
        spacing: 6

        Pfppanel {
            Layout.alignment: Qt.AlignVCenter
        }
    }
}
