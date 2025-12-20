import QtQuick
import Quickshell
import Quickshell.Wayland

PanelWindow {
    property string imagePath: ""
    
    visible: true
    color: "transparent"
    WlrLayershell.layer: WlrLayer.Background
    anchors { top: true; bottom: true; left: true; right: true }
    
    Image {
        anchors.fill: parent
        source: imagePath ? ("file://" + imagePath) : ""
        fillMode: Image.PreserveAspectCrop
        smooth: true
    }
}