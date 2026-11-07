pragma Singleton

import QtQuick
import Quickshell

// Runtime state shared by every ArchPill window (one per monitor).
Singleton {
    // When true the pill stays open even without the mouse on it
    // (toggled by `qs -c archpill ipc call archpill toggle`).
    property bool pinned: false
}
