pragma Singleton

import QtQuick
import Quickshell
import qs

// Every widget you can put in the control centre.
//
//  - Built-in widgets are listed below. "wide" ones take a full row, the
//    others are half-width tiles. Widgets with `run` are buttons whose command
//    depends on your desktop (see services/Desktop.qml); `action` is a fixed
//    command; `kdeOnly` ones only show up on KDE Plasma. They all share
//    widgets/ActionTile.qml.
//  - "app:<desktop-file-id>" shows any installed app as a launcher tile,
//    e.g. "app:org.kde.dolphin.desktop".
//  - "custom:<id>" shows one of your own buttons from
//    "controlCenter.customButtons" (make them in the settings app).
//
// Nothing here costs anything until you add it.
Singleton {
    id: root

    readonly property var categories: ["Connectivity", "Sound & Display", "Media", "Info", "Tools", "Windows & Desktop", "Power", "ArchPill"]

    function kwinShortcut(name) {
        return ["dbus-send", "--session", "--type=method_call", "--dest=org.kde.kglobalaccel", "/component/kwin", "org.kde.kglobalaccel.Component.invokeShortcut", "string:" + name];
    }

    readonly property var builtin: [
        // Connectivity
        { id: "wifi", name: "Wi-Fi", icon: "wifi", category: "Connectivity", desc: "Turn Wi-Fi on/off, shows the network. Right-click for settings." },
        { id: "bluetooth", name: "Bluetooth", icon: "bluetooth", category: "Connectivity", desc: "Turn Bluetooth on/off, shows connected devices." },
        { id: "airplane", name: "Airplane Mode", icon: "airplane", category: "Connectivity", desc: "Turns off Wi-Fi, mobile data and Bluetooth at once." },
        { id: "netsettings", name: "Network Settings", icon: "web", category: "Connectivity", run: "netsettings" },
        { id: "btsettings", name: "Bluetooth Settings", icon: "bluetooth", category: "Connectivity", run: "btsettings" },

        // Sound & Display
        { id: "volume", name: "Volume", icon: "volume-up", category: "Sound & Display", wide: true, desc: "Speaker volume slider." },
        { id: "micvolume", name: "Microphone Volume", icon: "mic", category: "Sound & Display", wide: true, desc: "Microphone level slider." },
        { id: "mic", name: "Microphone", icon: "mic", category: "Sound & Display", desc: "Mute/unmute the microphone." },
        { id: "output", name: "Sound Output", icon: "speaker", category: "Sound & Display", wide: true, desc: "Pick speakers, headphones or HDMI." },
        { id: "mixer", name: "App Volumes", icon: "equalizer", category: "Sound & Display", wide: true, desc: "Volume for each app that is playing sound." },
        { id: "brightness", name: "Brightness", icon: "sun", category: "Sound & Display", wide: true, desc: "Screen brightness slider." },
        { id: "nightlight", name: "Night Light", icon: "bulb", category: "Sound & Display", desc: "Warmer colours in the evening (Plasma Night Light)." },
        { id: "darkmode", name: "Dark Mode", icon: "contrast", category: "Sound & Display", desc: "Switch Plasma between light and dark colours." },
        { id: "soundsettings", name: "Sound Settings", icon: "speaker", category: "Sound & Display", run: "soundsettings" },
        { id: "displaysettings", name: "Display Settings", icon: "desktop", category: "Sound & Display", run: "displaysettings" },

        // Media
        { id: "media", name: "Now Playing", icon: "music", category: "Media", wide: true, desc: "Song, art and controls." },
        { id: "playpause", name: "Play / Pause", icon: "play", category: "Media", desc: "Play or pause the current player." },
        { id: "nexttrack", name: "Next Track", icon: "next", category: "Media", desc: "Skip to the next song." },

        // Info
        { id: "battery", name: "Battery", icon: "bolt", category: "Info", wide: true, desc: "Charge level and time left." },
        { id: "clock", name: "Clock & Date", icon: "timer", category: "Info", wide: true, desc: "Big clock and full date." },
        { id: "calendar", name: "Calendar", icon: "calendar", category: "Info", wide: true, desc: "This month, flip through months." },
        { id: "weather", name: "Weather", icon: "cloud", category: "Info", wide: true, desc: "Current weather from wttr.in (needs internet)." },
        { id: "stats", name: "System Monitor", icon: "chip", category: "Info", wide: true, desc: "CPU, memory and disk use (updates only while open)." },
        { id: "cpu", name: "CPU", icon: "chip", category: "Info", wide: true, desc: "CPU use with a graph, speed and temperature." },
        { id: "ram", name: "Memory (RAM)", icon: "chart", category: "Info", wide: true, desc: "RAM and swap use with a graph." },
        { id: "gpu", name: "GPU", icon: "gamepad", category: "Info", wide: true, desc: "Graphics use with a graph (AMD/NVIDIA usage, Intel clock speed), VRAM, temperature." },
        { id: "sysinfo", name: "System Info", icon: "info", category: "Info", wide: true, desc: "Computer name, kernel, uptime." },

        // Tools
        { id: "dnd", name: "Do Not Disturb", icon: "moon", category: "Tools", desc: "Stop notifications popping up in the pill (they still go to the history)." },
        { id: "notifications", name: "Notifications", icon: "bell", category: "Tools", wide: true, desc: "Notification history with Clear all." },
        { id: "caffeine", name: "Stay Awake", icon: "coffee", category: "Tools", desc: "Stop the screen from turning off / the PC from sleeping." },
        { id: "timer", name: "Timer", icon: "timer", category: "Tools", wide: true, desc: "Stopwatch and countdown." },
        { id: "clipboard", name: "Clipboard", icon: "clipboard", category: "Tools", wide: true, desc: "Last copied items from Plasma's clipboard. Click to copy again." },
        { id: "screenshot", name: "Screenshot", icon: "camera", category: "Tools", run: "screenshot" },
        { id: "screenshotfull", name: "Full Screenshot", icon: "camera", category: "Tools", run: "screenshotfull" },
        { id: "record", name: "Screen Recording", icon: "videocam", category: "Tools", run: "record" },
        { id: "emoji", name: "Emoji Picker", icon: "emoji", category: "Tools", run: "emoji" },
        { id: "keyboard", name: "Next Keyboard Layout", icon: "keyboard", category: "Tools", run: "keyboard" },
        { id: "clipboardmenu", name: "Clipboard Menu", icon: "clipboard", category: "Tools", kdeOnly: true, action: ["dbus-send", "--session", "--type=method_call", "--dest=org.kde.klipper", "/klipper", "org.kde.klipper.klipper.showKlipperPopupMenu"] },
        { id: "emptytrash", name: "Empty Trash", icon: "trash", category: "Tools", action: ["gio", "trash", "--empty"] },
        { id: "terminal", name: "Terminal", icon: "terminal", category: "Tools", run: "terminal" },
        { id: "files", name: "Files", icon: "folder", category: "Tools", run: "files" },
        { id: "sysmonitor", name: "System Monitor App", icon: "chart", category: "Tools", run: "sysmonitor" },
        { id: "systemsettings", name: "System Settings", icon: "settings", category: "Tools", run: "systemsettings" },

        // Windows & Desktop
        { id: "overview", name: "Overview", icon: "windows", category: "Windows & Desktop", kdeOnly: true, action: kwinShortcut("Overview") },
        { id: "showdesktop", name: "Show Desktop", icon: "desktop", category: "Windows & Desktop", kdeOnly: true, action: kwinShortcut("Show Desktop") },
        { id: "allwindows", name: "All Windows", icon: "apps", category: "Windows & Desktop", kdeOnly: true, action: kwinShortcut("ExposeAll") },
        { id: "gridview", name: "Desktop Grid", icon: "windows", category: "Windows & Desktop", kdeOnly: true, action: kwinShortcut("Grid View") },
        { id: "search", name: "App Launcher / Search", icon: "search", category: "Windows & Desktop", run: "search" },

        // Power
        { id: "power", name: "Power Buttons", icon: "power", category: "Power", wide: true, desc: "Lock, Sleep and Log out in one row." },
        { id: "lock", name: "Lock Screen", icon: "lock", category: "Power", run: "lock" },
        { id: "sleep", name: "Sleep", icon: "moon", category: "Power", run: "sleep" },
        { id: "hibernate", name: "Hibernate", icon: "snowflake", category: "Power", run: "hibernate" },
        { id: "logout", name: "Log Out", icon: "logout", category: "Power", run: "logout", confirm: true },
        { id: "restart", name: "Restart", icon: "restart", category: "Power", run: "restart", confirm: true },
        { id: "shutdown", name: "Shut Down", icon: "power", category: "Power", run: "shutdown", confirm: true },

        // ArchPill
        { id: "archpillsettings", name: "ArchPill Settings", icon: "palette", category: "ArchPill", desc: "Open the ArchPill settings app." },
        { id: "update", name: "Update ArchPill", icon: "download", category: "ArchPill", desc: "Check GitHub for a new version and install it." }
    ]

    // Look up any widget id, including "app:..." and "custom:...".
    function info(id) {
        id = String(id);
        if (id.indexOf("app:") === 0) {
            const appId = id.slice(4);
            const entry = DesktopEntries.byId(appId);
            return { id: id, name: entry ? entry.name : appId, icon: "apps", category: "Apps", wide: false, app: appId };
        }
        if (id.indexOf("custom:") === 0) {
            const b = customButton(id.slice(7));
            return b ? { id: id, name: b.name || "Button", icon: b.icon || "star", category: "Custom", wide: false, custom: b } : null;
        }
        for (let i = 0; i < builtin.length; i++)
            if (builtin[i].id === id)
                return builtin[i];
        return null;
    }

    function customButton(cid) {
        const list = Config.customButtons || [];
        for (let i = 0; i < list.length; i++)
            if (list[i] && list[i].id === cid)
                return list[i];
        return null;
    }

    // Can this widget work on the current desktop?
    function supported(w) {
        if (!w)
            return false;
        if (w.kdeOnly)
            return Desktop.isKde;
        if (w.run)
            return Desktop.can(w.run);
        if (w.id === "nightlight")
            return Plasma.nightLightSupported;
        if (w.id === "darkmode")
            return Plasma.darkModeSupported;
        if (w.id === "clipboard")
            return Desktop.isKde || Desktop.has("cliphist");
        return true;
    }

    // The catalogue: only widgets that work here.
    readonly property var available: builtin.filter(w => supported(w))

    function inCategory(cat) {
        return available.filter(w => w.category === cat);
    }
}
