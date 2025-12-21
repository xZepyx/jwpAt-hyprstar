//@pragma UseQApplication

import QtQuick
import Quickshell
import qs.bar
import qs.bar.placeholders
import qs.services
import "components/lockscreen" as Locks

ShellRoot {
    id: root

    Variants {
        model: Quickshell.screens
    
        Wallpaper {
            screen: modelData
            imagePath: Quickshell.env("HOME") + "/.config/quickshell/assets/wallpapers/wall.png"
        }
    }

    Loader {
        active: true
        sourceComponent: Bar {}
    }

    Loader {
        active: true
        sourceComponent: Mask {}
    }

    Locks.Lockscreen { id: lockscreen }

}
