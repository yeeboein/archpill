pragma Singleton

import QtQuick
import Quickshell
import qs

// Runtime state shared by every ArchPill window (one per monitor).
Singleton {
    id: root

    // When true the pill stays open even without the mouse on it
    // (toggled by `qs -c archpill ipc call archpill toggle`).
    property bool pinned: false

    // Which big view the pill is expanded into: "" (normal), "media" or "control".
    property string expanded: ""
    // The monitor it is expanded on ("" = the first one).
    property string screenName: ""
    // Control centre sub-page: "" (main), "wifi" or "bluetooth".
    property string ccPage: ""
    // Wi-Fi network waiting for a password ("" = none).
    property string wifiPasswordFor: ""
    // Control centre "edit widgets" mode.
    property bool editing: false
    // Do Not Disturb (silences ArchPill notifications once they exist).
    property bool dnd: false
    // The settings app window.
    property bool settingsOpen: false
    // The first-run welcome tour.
    property bool welcomeOpen: false

    // Popup: "", "volume" or "brightness". Shown briefly when they change.
    property string osd: ""
    property string lastOsd: "volume" // keeps the right icon while the popup fades out
    function showOsd(kind) {
        osd = kind;
        lastOsd = kind;
        osdTimer.restart();
    }
    Timer {
        id: osdTimer
        interval: Config.osdDuration
        onTriggered: root.osd = ""
    }

    function open(mode, screen) {
        screenName = screen || "";
        expanded = mode;
        editing = false;
        ccPage = "";
    }
    function close() {
        expanded = "";
        editing = false;
        ccPage = "";
    }
    function toggle(mode, screen) {
        if (expanded === mode && (screenName === (screen || "") || !screen))
            close();
        else
            open(mode, screen);
    }
}
