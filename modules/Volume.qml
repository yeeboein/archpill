import QtQuick
import qs
import qs.components
import qs.services

// Speaker volume. Scroll to change, click to mute/unmute.
Item {
    id: root

    property bool shown: Audio.ready
    // Set by the pill when it stands vertically on a screen side.
    property bool vertical: false

    implicitWidth: row.implicitWidth
    implicitHeight: Math.max(row.implicitHeight, 24)

    Grid {
        id: row
        // One row normally, one column in a vertical pill (left/right side).
        rows: root.vertical ? -1 : 1
        columns: root.vertical ? 1 : -1
        horizontalItemAlignment: Grid.AlignHCenter
        verticalItemAlignment: Grid.AlignVCenter
        rowSpacing: 2
        anchors.verticalCenter: parent.verticalCenter
        columnSpacing: 5

        Icon {
            size: 16
            color: Audio.muted ? Config.subtle : Config.foreground
            name: Audio.muted ? "volume-off" : Audio.volume < 0.01 ? "volume-mute" : Audio.volume < 0.5 ? "volume-down" : "volume-up"
        }
        PillText {
            id: pct
            visible: Config.volumeShowPercent
            text: Audio.percent + "%"
            color: Audio.muted ? Config.subtle : Config.foreground
            // fixed width so the pill doesn't wobble while scrolling
            width: Math.max(implicitWidth, metrics.width)
            horizontalAlignment: root.vertical ? Text.AlignHCenter : Text.AlignRight
            sizeFactor: root.vertical ? 0.8 : 1
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
