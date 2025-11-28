import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.services as Services

Item {
    id: root
    implicitHeight: 28
    implicitWidth: 210
    Layout.preferredWidth: implicitWidth
    Layout.alignment: Qt.AlignVCenter

    // theme
    property color bg: "#313244"
    property color text: "#cdd6f4"
    property color btnBg: "#313244"
    property color btnHover: "#2f3042"
    property color btnPress: "#2a2b3a"

    readonly property var mpris: Services.Mpris
    readonly property string line: (mpris.albumArtist || "No Artist") + " - " + (mpris.albumTitle || "No Media")

    // playback state
    property bool isPlaying: false
    property bool needsMarquee: false
    property int fadeW: 12

    Process { id: playPauseProc; command: ["playerctl", "play-pause"] }

    Process {
        id: statusProc
        command: ["bash", "-lc", "playerctl status 2>/dev/null || echo Stopped"]
        stdout: StdioCollector {
            onStreamFinished: root.isPlaying = (text.trim() === "Playing")
        }
    }

    Timer {
        interval: 800
        repeat: true
        running: true
        triggeredOnStart: true
        onTriggered: {
            statusProc.running = false
            statusProc.running = true
        }
    }

    Rectangle {
        anchors.fill: parent
        radius: 14
        color: root.bg
        antialiasing: true

        RowLayout {
            anchors.fill: parent
            anchors.margins: 4
            spacing: 8

            // play/pause button
            Rectangle {
                id: btn
                width: 20
                height: 20
                radius: 20
                color: btnMouse.pressed ? root.btnPress : (btnMouse.containsMouse ? root.btnHover : root.btnBg)
                border.width: 1
                border.color: "#45475a"
                Layout.alignment: Qt.AlignVCenter
                Behavior on color { ColorAnimation { duration: 120 } }

                Text {
                    anchors.centerIn: parent
                    text: root.isPlaying ? "󰏤" : "󰐊"   // pause / play
                    font.family: "Hack Nerd Font"
                    font.pixelSize: 14
                    color: root.text
                    opacity: 0.95
                }

                MouseArea {
                    id: btnMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        playPauseProc.running = false
                        playPauseProc.running = true
                        statusProc.running = false
                        statusProc.running = true
                    }
                }
            }

            // ---- marquee viewport ----
            Item {
                id: viewport
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter
                height: 20
                clip: true

                Row {
                    id: marqueeRow
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 22
                    x: 0

                    Text {
                        id: textA
                        text: root.line
                        color: root.text
                        font.pixelSize: 13
                        font.weight: 600
                        elide: Text.ElideNone
                    }

                    Text {
                        id: textB
                        text: textA.text
                        color: root.text
                        font.pixelSize: 13
                        font.weight: 600
                        elide: Text.ElideNone
                        visible: root.needsMarquee
                    }
                }

                // LEFT fade
                Item {
                    z: 10
                    visible: root.needsMarquee
                    width: root.fadeW
                    anchors.left: parent.left
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    clip: true

                    Rectangle {
                        anchors.centerIn: parent
                        width: parent.height
                        height: parent.width
                        rotation: -90
                        transformOrigin: Item.Center
                        gradient: Gradient {
                            GradientStop { position: 0.0; color: root.bg }
                            GradientStop { position: 1.0; color: "transparent" }
                        }
                    }
                }

                // RIGHT fade
                Item {
                    z: 10
                    visible: root.needsMarquee
                    width: root.fadeW
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    clip: true

                    Rectangle {
                        anchors.centerIn: parent
                        width: parent.height
                        height: parent.width
                        rotation: -90
                        transformOrigin: Item.Center
                        gradient: Gradient {
                            GradientStop { position: 0.0; color: "transparent" }
                            GradientStop { position: 1.0; color: root.bg }
                        }
                    }
                }

                // ✅ 1s delay before scrolling starts
                Timer {
                    id: marqueeDelay
                    interval: 1000
                    repeat: false
                    onTriggered: {
                        if (root.needsMarquee) marqueeAnim.start()
                    }
                }

                function recompute(resetPosition) {
                    const usable = Math.max(0, viewport.width - (root.fadeW * 2))
                    root.needsMarquee = textA.paintedWidth > usable

                    // stop everything first
                    marqueeAnim.stop()
                    marqueeDelay.stop()

                    // reset if asked OR if it fits
                    if (resetPosition || !root.needsMarquee) {
                        marqueeRow.x = 0
                    }

                    // only scroll when needed, after delay
                    if (root.needsMarquee) {
                        marqueeAnim.from = 0
                        marqueeAnim.to = -(textA.paintedWidth + marqueeRow.spacing)
                        marqueeDelay.start()
                    }
                }

                onWidthChanged: recompute(false)
                Component.onCompleted: recompute(true)

                Connections {
                    target: root.mpris
                    function onAlbumArtistChanged() { viewport.recompute(true) }
                    function onAlbumTitleChanged()  { viewport.recompute(true) }
                }

                NumberAnimation {
                    id: marqueeAnim
                    target: marqueeRow
                    property: "x"
                    from: 0
                    to: -(textA.paintedWidth + marqueeRow.spacing)
                    duration: Math.max(12000, textA.paintedWidth * 22)
                    loops: Animation.Infinite
                    easing.type: Easing.Linear
                    running: false
                }
            }
        }
    }
}
