import QtQuick
import qs
import qs.components
import qs.services

// Current temperature. Refreshes at most every 30 minutes while visible.
Item {
    id: root
    property bool shown: Weather.ok
    implicitWidth: t.implicitWidth
    implicitHeight: t.implicitHeight

    PillText {
        id: t
        text: Weather.icon + " " + Weather.temp
    }
    // Check every 10 minutes; the service only really fetches every 30.
    Timer {
        interval: 600000
        repeat: true
        triggeredOnStart: true
        running: true
        onTriggered: Weather.refresh(false)
    }
}
