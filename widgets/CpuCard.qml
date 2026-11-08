import QtQuick
import qs.components
import qs.services

StatCard {
    icon: "chip"
    title: "CPU"
    value: Math.round(SystemStats.cpu * 100) + "%"
    fraction: SystemStats.cpu
    history: SystemStats.cpuHistory
    details: [SystemStats.cores > 0 ? SystemStats.cores + " threads" : "", SystemStats.cpuFreq > 0 ? (SystemStats.cpuFreq / 1000).toFixed(2) + " GHz" : "", SystemStats.cpuTemp >= 0 ? Math.round(SystemStats.cpuTemp) + "°C" : ""].filter(s => s).join("  ·  ")
    Component.onCompleted: SystemStats.watchers++
    Component.onDestruction: SystemStats.watchers--
}
