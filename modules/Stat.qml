import QtQuick
import qs
import qs.components
import qs.services

// Small CPU / RAM / GPU / temperature reading for the pill.
// kind: "cpu", "ram", "gpu" or "temp".
Item {
    id: root
    property bool shown: true
    // Set by the pill when it stands vertically on a screen side.
    property bool vertical: false
    property string kind: "cpu"

    readonly property real frac: kind === "cpu" ? SystemStats.cpu : kind === "ram" ? SystemStats.mem : kind === "gpu" ? Math.max(0, SystemStats.gpu) : Math.min(1, Math.max(0, (SystemStats.cpuTemp - 30) / 70))
    readonly property string label: kind === "cpu" ? "CPU" : kind === "ram" ? "RAM" : kind === "gpu" ? "GPU" : ""
    readonly property string value: kind === "temp" ? (SystemStats.cpuTemp >= 0 ? Math.round(SystemStats.cpuTemp) + "°" : "—") : kind === "gpu" && SystemStats.gpu < 0 ? "—" : Math.round(frac * 100) + "%"

    implicitWidth: row.implicitWidth
    implicitHeight: row.implicitHeight

    Component.onCompleted: SystemStats.watchers++
    Component.onDestruction: SystemStats.watchers--

    Grid {
        id: row
        // One row normally, one column in a vertical pill (left/right side).
        rows: root.vertical ? -1 : 1
        columns: root.vertical ? 1 : -1
        horizontalItemAlignment: Grid.AlignHCenter
        verticalItemAlignment: Grid.AlignVCenter
        rowSpacing: 2
        columnSpacing: 5
        Icon {
            size: 14
            name: root.kind === "ram" ? "chart" : root.kind === "gpu" ? "gamepad" : root.kind === "temp" ? "snowflake" : "chip"
            color: root.frac > 0.85 ? Config.critical : root.frac > 0.65 ? Config.warning : Config.subtle
        }
        PillText {
            text: root.value
            // fixed width so the pill doesn't wobble
            width: root.vertical ? implicitWidth : Math.max(implicitWidth, 32)
            sizeFactor: root.vertical ? 0.8 : 1
        }
    }
}
