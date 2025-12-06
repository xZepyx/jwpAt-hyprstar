//@pragma UseQApplication

import QtQuick
import Quickshell
import qs.bar
import qs.bar.placeholders
import qs.services

ShellRoot {
    id: root

    Variants {
        model: Quickshell.screens
    
        Wallpaper {
            screen: modelData
            imagePath: Quickshell.env("HOME") + "/.config/wallpapers/catppuccin/sunset.jpg"
        }
    }

    Loader {
        active: true
        sourceComponent: Bar {}
    }

    Loader {
        active: false
        sourceComponent: Bottombar {}
    }

    Loader {
        active: true
        sourceComponent: Rightbar {}
    }

    Loader {
        active: true
        sourceComponent: Leftbar {}
    }

    Loader {
        active: true
        sourceComponent: Mask {}
    }
}
