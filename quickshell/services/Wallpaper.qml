import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.theme

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
    
    // Add this connection to react to theme changes
    Connections {
        target: Theme
        function onCurrentChanged() {
            const home = Quickshell.env("HOME")
            const base = home + "/.config/quickshell/assets/wallpapers/"
            imagePath = base + (Theme.current === "Oled" ? "oled.png" : "catppuccin.png")
        }
    }
    
    // Set initial wallpaper on component load
    Component.onCompleted: {
        const home = Quickshell.env("HOME")
        const base = home + "/.config/quickshell/assets/wallpapers/"
        imagePath = base + (Theme.current === "Oled" ? "oled.png" : "catppuccin.png")
    }
}