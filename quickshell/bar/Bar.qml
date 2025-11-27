import Quickshell
import QtQuick
import QtQuick.Effects
import qs.modules

PanelWindow {
    id: topBar
    implicitHeight: 40
    color: "transparent"

    anchors {
        top: true
        left: true
        right: true
    }

    Row {
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        spacing: 6
        padding: 6

        DateTime {}

        Battery {}
    }

    Workspaces {
        id: workspaces
        anchors {
            horizontalCenter: parent.horizontalCenter
            verticalCenter: parent.verticalCenter
        }
    }

    Row {
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        spacing: 6 
        padding: 6

        Pfppanel {}
    }
}
