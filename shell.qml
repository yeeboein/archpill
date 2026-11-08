// ArchPill - a Dynamic Island-style pill for KDE Plasma (Wayland).
// Run with:  qs -c archpill
import QtQuick
import Quickshell
import Quickshell.Io
import qs
import qs.services
import qs.settings

ShellRoot {
    id: root

    // Screens to show the pill on: the one named in "pill.monitor",
    // or all screens if it's empty / not found.
    function pickScreens(monitor) {
        const all = [];
        for (let i = 0; i < Quickshell.screens.length; i++)
            all.push(Quickshell.screens[i]);
        if (!monitor)
            return all;
        const match = all.filter(s => s.name === monitor);
        if (match.length === 0)
            console.warn("[archpill] monitor \"" + monitor + "\" not found, using all screens");
        return match.length > 0 ? match : all;
    }

    Variants {
        model: root.pickScreens(Config.monitor)
        Pill {}
    }

    // The settings app window, only created while it's open.
    LazyLoader {
        active: PillState.settingsOpen
        SettingsApp {}
    }

    // First-run welcome tour.
    LazyLoader {
        active: PillState.welcomeOpen
        WelcomeWizard {}
    }
    // Show it shortly after the first start (until you finish or close it).
    Timer {
        interval: 1500
        running: true
        onTriggered: if (!Config.get("setup.done", false)) PillState.welcomeOpen = true
    }

    // Commands you can run from a terminal or bind to a key, e.g.
    //   qs -c archpill ipc call archpill toggle
    IpcHandler {
        target: "archpill"

        // Keep the pill open / let it hide again.
        function toggle(): void {
            PillState.pinned = !PillState.pinned;
        }
        function show(): void {
            PillState.pinned = true;
        }
        function hide(): void {
            PillState.pinned = false;
        }
        // Open/close the control centre or the music dropdown.
        function toggleControlCenter(): void {
            PillState.toggle("control", "");
        }
        function toggleMedia(): void {
            PillState.toggle("media", "");
        }
        function close(): void {
            PillState.close();
        }
        // Open / close the ArchPill settings app.
        function openSettings(): void {
            PillState.settingsOpen = true;
        }
        function closeSettings(): void {
            PillState.settingsOpen = false;
        }
        // Show the welcome tour again.
        function welcome(): void {
            PillState.welcomeOpen = true;
        }
        // Re-read ~/.config/archpill/config.json (normally automatic).
        function reloadConfig(): void {
            Config.reload();
        }
        // Media keys for the player ArchPill shows.
        function playPause(): void {
            Players.togglePlaying();
        }
        function next(): void {
            Players.next();
        }
        function previous(): void {
            Players.previous();
        }
    }
}
