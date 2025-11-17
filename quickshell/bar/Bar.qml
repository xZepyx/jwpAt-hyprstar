import Quickshell
import QtQuick
import QtQuick.Effects
import qs.modules
import qs.services as Services

PanelWindow {
    id: topBar
    implicitHeight: 36
    color: "transparent"

    anchors {
        top: true
        left: true
        right: true
    }

    Services.Power {
        id: powerSvc
    }

    Row {
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        spacing: 5
        padding: 5

        DateTime {}

        Battery {
            visible: powerSvc.hasBattery
        }
    }

    Workspaces {
        id: workspaces
        anchors {
            horizontalCenter: parent.horizontalCenter
            verticalCenter: parent.verticalCenter
        }
    }
}
