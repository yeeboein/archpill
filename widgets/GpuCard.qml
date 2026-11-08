import QtQuick
import qs.components
import qs.services

StatCard {
    icon: "gamepad"
    title: SystemStats.gpuName || "GPU"
    value: SystemStats.gpu < 0 ? "—" : Math.round(SystemStats.gpu * 100) + "%"
    fraction: Math.max(0, SystemStats.gpu)
    history: SystemStats.gpuHistory
    details: SystemStats.gpu < 0 ? "No GPU readings available" : [SystemStats.gpuIsClock ? "clock " + Math.round(SystemStats.gpuFreq) + " / " + Math.round(SystemStats.gpuMaxFreq) + " MHz" : "", SystemStats.vramTotal > 0 ? "VRAM " + SystemStats.vramUsed.toFixed(1) + " / " + SystemStats.vramTotal.toFixed(1) + " GB" : "", SystemStats.gpuTemp >= 0 ? Math.round(SystemStats.gpuTemp) + "°C" : ""].filter(s => s).join("  ·  ")
    Component.onCompleted: SystemStats.watchers++
    Component.onDestruction: SystemStats.watchers--
}
