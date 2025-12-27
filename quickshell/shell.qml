//@pragma UseQApplication

import QtQuick
import Quickshell
import qs.bar
import qs.bar.placeholders
import qs.services
import "modules/lockscreen" as Locks
import "modules/menus"

ShellRoot {
    id: root

    ThemeMenu {
        id: themeMenu
    }

    Variants {
        model: Quickshell.screens
        Wallpaper {
            screen: modelData
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
