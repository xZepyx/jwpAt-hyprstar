// services/Power.qml
import QtQuick
import Quickshell.Services.UPower

QtObject {
    id: svc
    readonly property bool hasBattery: UPower.devices.count > 0
}
