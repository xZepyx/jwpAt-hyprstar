//@pragma UseQApplication

import QtQuick
import Quickshell
import "./modules/bar/"
import "./modules/bar/placeholders"
import "./modules/widgets/"

ShellRoot {
    id: root

    Loader {
        active: true
        sourceComponent: Bar {}
    }

    Loader {
        active: true
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