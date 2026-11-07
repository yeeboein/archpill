import QtQuick
import Quickshell.Services.UPower
import qs
import qs.components

Card {
    id: card
    readonly property var dev: UPower.displayDevice
    readonly property bool hasBattery: !!dev && dev.ready && (dev.isLaptopBattery || (dev.isPresent && dev.type === UPowerDeviceType.Battery))
    readonly property int percent: dev ? Math.round(Math.max(0, Math.min(1, dev.percentage)) * 100) : 0
    readonly property bool charging: !!dev && (dev.state === UPowerDeviceState.Charging || dev.state === UPowerDeviceState.PendingCharge)

    function dur(sec) {
        if (!sec || sec <= 0)
            return "";
        const h = Math.floor(sec / 3600), m = Math.round((sec % 3600) / 60);
        return (h > 0 ? h + " h " : "") + m + " min";
    }

    Row {
        width: parent.width
        spacing: 12

        PillText {
            anchors.verticalCenter: parent.verticalCenter
            text: card.hasBattery ? card.percent + "%" : "—"
            sizeFactor: 1.9
            font.weight: Font.Bold
            color: card.hasBattery && !card.charging && card.percent <= Config.batteryLow ? Config.critical : Config.foreground
        }
        Column {
            anchors.verticalCenter: parent.verticalCenter
            PillText {
                text: !card.hasBattery ? "No battery" : card.charging ? "Charging" : !UPower.onBattery ? "Plugged in" : "On battery"
                font.weight: Font.DemiBold
            }
            PillText {
                visible: text !== ""
                color: Config.subtle
                sizeFactor: 0.85
                text: !card.hasBattery ? "" : card.charging ? (card.dur(card.dev.timeToFull) ? card.dur(card.dev.timeToFull) + " until full" : "") : (UPower.onBattery && card.dur(card.dev.timeToEmpty) ? card.dur(card.dev.timeToEmpty) + " left" : "")
            }
        }
    }
}
