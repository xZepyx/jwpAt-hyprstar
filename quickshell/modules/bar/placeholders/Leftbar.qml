import Quickshell
import QtQuick

PanelWindow {
    anchors {
        left: true
        top: true
        bottom: true
    }

    color: "transparent"
    implicitWidth: 7  // wider so the button fits

    Rectangle {
        anchors.fill: parent
        color: "transparent"

        Rectangle {
            id: button
            width: 7
            height: 240
            anchors.centerIn: parent
            color: "transparent"

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                onClicked: {
                    console.log("Test")
                    
                }
                onEntered: {
                    console.log("Hi!")
                }
                onExited: {
                    console.log("Bye!")
                }
            }
        }
    }
}
