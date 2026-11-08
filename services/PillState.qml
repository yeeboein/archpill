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
    // Control centre "edit widgets" mode.
    property bool editing: false
    // Do Not Disturb (silences ArchPill notifications once they exist).
    property bool dnd: false
    // The settings app window.
    property bool settingsOpen: false

    // Volume popup: "" or "volume". Shown briefly when the volume changes.
    property string osd: ""
    function showOsd(kind) {
        osd = kind;
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
    }
    function close() {
        expanded = "";
        editing = false;
    }
    function toggle(mode, screen) {
        if (expanded === mode && (screenName === (screen || "") || !screen))
            close();
        else
            open(mode, screen);
    }
}
