pragma Singleton

import QtQuick
import Quickshell

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
