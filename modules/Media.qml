import QtQuick
import qs
import qs.components
import qs.services

// Now playing: album art, title and artist. Click it for the big music
// dropdown. The small play/next/back buttons are hidden unless
// "media.showControls" is true. Which player is shown: services/Players.qml.
Item {
    id: root

    readonly property var player: Players.active
    property bool shown: Players.hasPlayer
    property string screenName: ""
    // Vertical pill: just the album art (click it for the big player).
    property bool vertical: false

    implicitWidth: row.implicitWidth
    implicitHeight: row.implicitHeight

    Row {
        id: row
        spacing: 8

        // Album art (falls back to a music note).
        Rectangle {
            visible: Config.showArt || root.vertical
            width: 26
            height: 26
            radius: 6
            anchors.verticalCenter: parent.verticalCenter
            color: Qt.rgba(Config.foreground.r, Config.foreground.g, Config.foreground.b, 0.1)
            clip: true

            Icon {
                anchors.centerIn: parent
                visible: art.status !== Image.Ready
                size: 14
                name: "music"
                color: Config.subtle
            }
            Image {
                id: art
                anchors.fill: parent
                source: root.player ? (root.player.trackArtUrl || "") : ""
                sourceSize: Qt.size(52, 52)
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
                cache: true
                visible: status === Image.Ready
            }
        }

        Column {
            id: titles
            visible: !root.vertical
            anchors.verticalCenter: parent.verticalCenter
            width: Math.min(Config.maxTitleWidth, Math.max(title.implicitWidth, artist.implicitWidth))

            PillText {
                id: title
                width: parent.width
                text: root.player ? root.player.trackTitle : ""
                font.weight: Font.DemiBold
            }
            PillText {
                id: artist
                width: parent.width
                visible: text !== ""
                text: root.player ? (root.player.trackArtist || root.player.trackAlbum || root.player.identity || "") : ""
                color: Config.subtle
                sizeFactor: 0.85
            }
        }

        Row {
            visible: Config.mediaShowControls && !root.vertical
            anchors.verticalCenter: parent.verticalCenter
            spacing: 0

            IconButton {
                icon: "previous"
                size: 15
                enabledAction: !!root.player && root.player.canGoPrevious
                onClicked: Players.previous()
            }
            IconButton {
                icon: root.player && root.player.isPlaying ? "pause" : "play"
                size: 17
                enabledAction: !!root.player && root.player.canTogglePlaying
                onClicked: Players.togglePlaying()
            }
            IconButton {
                icon: "next"
                size: 15
                enabledAction: !!root.player && root.player.canGoNext
                onClicked: Players.next()
            }
        }
    }

    // Click the song to open the big music dropdown.
    MouseArea {
        x: 0
        width: root.vertical ? parent.width : titles.x + titles.width
        height: parent.height
        cursorShape: Qt.PointingHandCursor
        onClicked: PillState.toggle("media", root.screenName)
    }
}
