import Quickshell
import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
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

    // LEFT
    Row {
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        spacing: 6
        padding: 6

        DateTime {}
        Battery {}
    }

    // CENTER (Workspaces centered, Media to the right)
    RowLayout {
        id: centerCluster
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        spacing: 8

        // Mirror spacer so Workspaces stays perfectly centered
        Item {
            Layout.preferredWidth: media.implicitWidth
            Layout.preferredHeight: 1
        }

        Workspaces {
            Layout.alignment: Qt.AlignVCenter
        }

        Mediaplayer {
            id: media
            Layout.alignment: Qt.AlignVCenter
        }
    }

    // RIGHT
    Row {
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        spacing: 6
        padding: 6

        Pfppanel {}
    }
}
