import QtQuick
import Quickshell.Services.UPower
import qs
import qs.components

// Laptop battery level, with a lightning bolt while charging.
// Hidden automatically on computers without a battery.
Item {
    id: root

    readonly property var dev: UPower.displayDevice
    property bool shown: !!dev && dev.ready && (dev.isLaptopBattery || (dev.isPresent && dev.type === UPowerDeviceType.Battery))
    // Set by the pill when it stands vertically on a screen side.
    property bool vertical: false

    // percentage is 0..1 in Quickshell
    readonly property real level: dev ? Math.max(0, Math.min(1, dev.percentage)) : 0
    readonly property int percent: Math.round(level * 100)
    readonly property bool charging: !!dev && (dev.state === UPowerDeviceState.Charging || dev.state === UPowerDeviceState.PendingCharge)
    readonly property bool pluggedIn: !UPower.onBattery
    readonly property bool low: !pluggedIn && percent <= Config.batteryLow

    implicitWidth: row.implicitWidth
    implicitHeight: row.implicitHeight

    Grid {
        id: row
        // One row normally, one column in a vertical pill (left/right side).
        rows: root.vertical ? -1 : 1
        columns: root.vertical ? 1 : -1
        horizontalItemAlignment: Grid.AlignHCenter
        verticalItemAlignment: Grid.AlignVCenter
        rowSpacing: 2
        columnSpacing: 6

        Icon {
            visible: root.pluggedIn
            size: 13
            name: "bolt"
            color: root.charging ? Config.good : Config.subtle
        }

        // A tiny drawn battery (cheaper and crisper than an icon font).
        Item {
            width: 24
            height: 12

            Rectangle {
                id: body
                width: 21
                height: 12
                radius: 3.5
                color: "transparent"
                border.width: 1.2
                border.color: Qt.rgba(Config.foreground.r, Config.foreground.g, Config.foreground.b, 0.55)
            }
            Rectangle {
                x: body.width + 1
                anchors.verticalCenter: body.verticalCenter
                width: 1.6
                height: 4.5
                radius: 1
                color: body.border.color
            }
            Rectangle {
                x: 2.2
                y: 2.2
                height: body.height - 4.4
                width: Math.max(1.5, (body.width - 4.4) * root.level)
                radius: 1.8
                color: root.charging || (root.pluggedIn && root.percent >= 99) ? Config.good : root.low ? Config.critical : Config.foreground
            }
        }

        PillText {
            visible: Config.batteryShowPercent
            text: root.percent + "%"
            sizeFactor: root.vertical ? 0.8 : 1
            color: root.low ? Config.critical : Config.foreground
        }
    }
}
