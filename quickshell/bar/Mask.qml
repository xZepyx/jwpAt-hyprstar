//@ pragma UseQApplication
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import QtQuick
import QtQuick.Effects
import qs.theme as Theme

PanelWindow {
    id: root
    color: "transparent"
    visible: true
    WlrLayershell.exclusiveZone: -1
    mask: Region { item: container; intersection: Intersection.Xor }
    
    anchors {
        top: true
        left: true
        bottom: true
        right: true
    }
    
    Item {
        id: container
        anchors.fill: parent
        
        Rectangle {
            anchors.fill: parent
            
            // Use theme gradient colors - will auto-update on theme change!
            gradient: Gradient {
                GradientStop { position: 0.0; color: Theme.Theme.gradientTop }
                GradientStop { position: 1.0; color: Theme.Theme.gradientBottom }
            }
            
            // Smooth color transitions when theme changes
            Behavior on gradient {
                PropertyAnimation { duration: 300; easing.type: Easing.InOutQuad }
            }
            
            layer.enabled: true
            layer.effect: MultiEffect {
                maskSource: mask
                maskEnabled: true
                maskInverted: true
                maskThresholdMin: 0.5
                maskSpreadAtMin: 1
            }
        }
        
        Item {
            id: mask
            anchors.fill: parent
            layer.enabled: true
            visible: false
            
            Rectangle {
                anchors.fill: parent
                anchors.leftMargin: 0
                anchors.rightMargin: 0
                anchors.topMargin: 40
                anchors.bottomMargin: 0
                radius: 14
            }
        }
    }
}