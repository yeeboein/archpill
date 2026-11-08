import QtQuick
import qs
import qs.services

// Full "now playing" view: art, title, artist, progress bar, controls.
// `big: true` is the dropdown you get by clicking the song in the pill;
// `big: false` is the smaller card in the control centre.
Item {
    id: root

    property bool big: true
    readonly property var player: Players.active
    readonly property real artSize: big ? 104 : 58

    implicitHeight: player ? content.implicitHeight : empty.implicitHeight

    function fmt(sec) {
        if (!isFinite(sec) || sec < 0)
            sec = 0;
        const s = Math.floor(sec % 60), m = Math.floor(sec / 60) % 60, h = Math.floor(sec / 3600);
        const ss = (s < 10 ? "0" : "") + s;
        return h > 0 ? h + ":" + (m < 10 ? "0" : "") + m + ":" + ss : m + ":" + ss;
    }

    // MPRIS doesn't push position updates, so ask once a second -
    // only while this view is on screen and music is playing.
    Timer {
        interval: 1000
        repeat: true
        running: root.visible && !!root.player && root.player.isPlaying
        onTriggered: root.player.positionChanged()
    }

    PillText {
        id: empty
        visible: !root.player
        width: parent.width
        horizontalAlignment: Text.AlignHCenter
        topPadding: 10
        bottomPadding: 10
        text: "Nothing is playing"
        color: Config.subtle
    }

    Column {
        id: content
        visible: !!root.player
        width: parent.width
        spacing: root.big ? 14 : 8

        Row {
            width: parent.width
            spacing: 14

            Rectangle {
                width: root.artSize
                height: root.artSize
                radius: root.big ? 16 : 10
                color: Qt.rgba(Config.foreground.r, Config.foreground.g, Config.foreground.b, 0.1)
                clip: true
                Icon {
                    anchors.centerIn: parent
                    visible: art.status !== Image.Ready
                    size: root.artSize / 2.5
                    name: "music"
                    color: Config.subtle
                }
                Image {
                    id: art
                    anchors.fill: parent
                    // "Art spin": slowly turns while music plays (off by default).
                    RotationAnimation on rotation {
                        running: root.big && Config.anim("artSpin") && !!root.player && root.player.isPlaying && root.visible
                        loops: Animation.Infinite
                        from: 0
                        to: 360
                        duration: 20000
                    }
                    source: root.player ? (root.player.trackArtUrl || "") : ""
                    sourceSize: Qt.size(root.artSize * 2, root.artSize * 2)
                    fillMode: Image.PreserveAspectCrop
                    asynchronous: true
                    visible: status === Image.Ready
                }
            }

            Column {
                width: parent.width - root.artSize - 14
                anchors.verticalCenter: parent.verticalCenter
                spacing: 2

                PillText {
                    width: parent.width
                    text: root.player ? root.player.trackTitle : ""
                    font.weight: Font.Bold
                    sizeFactor: root.big ? 1.35 : 1.05
                    wrapMode: root.big ? Text.Wrap : Text.NoWrap
                    maximumLineCount: root.big ? 2 : 1
                }
                PillText {
                    width: parent.width
                    visible: text !== ""
                    text: root.player ? (root.player.trackArtist || "") : ""
                    color: Config.subtle
                    sizeFactor: root.big ? 1.05 : 0.9
                }
                PillText {
                    width: parent.width
                    visible: root.big && text !== ""
                    text: root.player ? (root.player.trackAlbum || "") : ""
                    color: Config.subtle
                    sizeFactor: 0.85
                }
                PillText {
                    width: parent.width
                    visible: root.big
                    text: Players.displayName(root.player)
                    color: Config.accent
                    sizeFactor: 0.8
                }
            }
        }

        // Progress bar (click to seek when the player allows it).
        Column {
            width: parent.width
            spacing: 4
            visible: !!root.player && root.player.lengthSupported && root.player.length > 0

            Item {
                width: parent.width
                height: 12
                Rectangle {
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width
                    height: 4
                    radius: 2
                    color: Qt.rgba(Config.foreground.r, Config.foreground.g, Config.foreground.b, 0.15)
                    Rectangle {
                        height: parent.height
                        radius: 2
                        color: Config.foreground
                        width: root.player && root.player.length > 0 ? parent.width * Math.min(1, root.player.position / root.player.length) : 0
                    }
                }
                MouseArea {
                    anchors.fill: parent
                    enabled: !!root.player && root.player.canSeek && root.player.positionSupported
                    cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                    onClicked: mouse => root.player.position = (mouse.x / width) * root.player.length
                }
            }
            Item {
                width: parent.width
                height: posText.implicitHeight
                visible: root.big
                PillText {
                    id: posText
                    text: root.player ? root.fmt(root.player.position) : ""
                    color: Config.subtle
                    sizeFactor: 0.8
                }
                PillText {
                    anchors.right: parent.right
                    text: root.player ? root.fmt(root.player.length) : ""
                    color: Config.subtle
                    sizeFactor: 0.8
                }
            }
        }

        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: root.big ? 18 : 10

            IconButton {
                anchors.verticalCenter: parent.verticalCenter
                icon: "previous"
                size: root.big ? 24 : 18
                enabledAction: !!root.player && root.player.canGoPrevious
                onClicked: Players.previous()
            }
            IconButton {
                anchors.verticalCenter: parent.verticalCenter
                icon: root.player && root.player.isPlaying ? "pause" : "play"
                size: root.big ? 34 : 24
                enabledAction: !!root.player && root.player.canTogglePlaying
                onClicked: Players.togglePlaying()
            }
            IconButton {
                anchors.verticalCenter: parent.verticalCenter
                icon: "next"
                size: root.big ? 24 : 18
                enabledAction: !!root.player && root.player.canGoNext
                onClicked: Players.next()
            }
        }

        // Switch between players when more than one has something loaded.
        Flow {
            width: parent.width
            spacing: 6
            visible: root.big && Players.candidates.length > 1

            Repeater {
                model: root.big ? Players.candidates : []
                delegate: Rectangle {
                    required property var modelData
                    readonly property bool current: modelData === root.player
                    width: chipText.implicitWidth + 20
                    height: 26
                    radius: 13
                    color: current ? Config.accent : Qt.rgba(Config.foreground.r, Config.foreground.g, Config.foreground.b, 0.1)
                    PillText {
                        id: chipText
                        anchors.centerIn: parent
                        text: Players.displayName(modelData)
                        sizeFactor: 0.85
                        color: parent.current ? "#ffffff" : Config.foreground
                    }
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: Players.choose(modelData)
                    }
                }
            }
        }
    }
}
