import QtQuick
import qs
import qs.components
import qs.services

// Speaker volume. Scroll to change, click to mute/unmute.
Item {
    id: root

    property bool shown: Audio.ready

    implicitWidth: row.implicitWidth
    implicitHeight: Math.max(row.implicitHeight, 24)

    Row {
        id: row
        anchors.verticalCenter: parent.verticalCenter
        spacing: 5

        Icon {
            anchors.verticalCenter: parent.verticalCenter
            size: 16
            color: Audio.muted ? Config.subtle : Config.foreground
            name: Audio.muted ? "volume-off" : Audio.volume < 0.01 ? "volume-mute" : Audio.volume < 0.5 ? "volume-down" : "volume-up"
        }
        PillText {
            id: pct
            visible: Config.volumeShowPercent
            anchors.verticalCenter: parent.verticalCenter
            text: Audio.percent + "%"
            color: Audio.muted ? Config.subtle : Config.foreground
            // fixed width so the pill doesn't wobble while scrolling
            width: Math.max(implicitWidth, metrics.width)
            horizontalAlignment: Text.AlignRight
            TextMetrics {
                id: metrics
                font: pct.font
                text: "100%"
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: Audio.toggleMute()

        // Mouse wheels send 120 per notch; touchpads send many small values.
        property real acc: 0
        onWheel: wheel => {
            acc += wheel.angleDelta.y;
            while (acc >= 120) {
                Audio.changeBy(1);
                acc -= 120;
            }
            while (acc <= -120) {
                Audio.changeBy(-1);
                acc += 120;
            }
        }
    }
}
