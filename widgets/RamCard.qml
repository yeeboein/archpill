import QtQuick
import qs.components
import qs.services

StatCard {
    icon: "chart"
    title: "Memory"
    value: Math.round(SystemStats.mem * 100) + "%"
    fraction: SystemStats.mem
    history: SystemStats.memHistory
    details: SystemStats.memUsed.toFixed(1) + " / " + SystemStats.memTotal.toFixed(1) + " GB" + (SystemStats.swapTotal > 0 ? "  ·  swap " + SystemStats.swapUsed.toFixed(1) + " / " + SystemStats.swapTotal.toFixed(1) + " GB" : "")
    Component.onCompleted: SystemStats.watchers++
    Component.onDestruction: SystemStats.watchers--
}
