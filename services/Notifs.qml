pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Notifications
import qs

// Notifications shown in the pill.
//
// ArchPill becomes the desktop's notification server
// (org.freedesktop.Notifications). Only one program can be that at a time; on
// KDE it's Plasma. If someone else has it, Quickshell just logs a warning and
// takes over automatically the moment the other one lets go - nothing breaks.
//
// handOver() turns off Plasma's Notifications item and restarts the panel so
// ArchPill gets them; giveBack() undoes it. uninstall.sh also gives them back.
Singleton {
    id: root

    // ---- who handles notifications right now ---------------------------------
    property string owner: ""             // "quickshell" = ArchPill, "Plasma", "dunst", "" = nobody/unknown
    readonly property bool active: owner === "quickshell"
    readonly property string ownerName: owner === "quickshell" ? "ArchPill" : owner === "" ? "nobody" : owner
    property string handoverStatus: ""    // progress / error text for the settings page

    function checkOwner() {
        if (!ownerCheck.running)
            ownerCheck.running = true;
    }
    Process {
        id: ownerCheck
        command: ["dbus-send", "--session", "--print-reply=literal", "--dest=org.freedesktop.Notifications", "/org/freedesktop/Notifications", "org.freedesktop.Notifications.GetServerInformation"]
        stdout: StdioCollector {
            onStreamFinished: root.owner = text.trim().split(/\s+/)[0] || ""
        }
        onExited: code => {
            if (code !== 0)
                root.owner = "";
        }
    }
    Timer {
        // first check shortly after start, and again after a handover
        id: ownerTimer
        interval: 3000
        running: true
        onTriggered: root.checkOwner()
    }

    // ---- Plasma handover (KDE) --------------------------------------------------
    // Edits the system tray's list of enabled items through Plasma's own
    // scripting interface, then restarts plasmashell so it lets go of
    // org.freedesktop.Notifications.
    function trayScript(enable) {
        return "var add = " + (enable ? "true" : "false") + "; panels().forEach(function(p) { p.widgets('org.kde.plasma.systemtray').forEach(function(w) { var st = desktopById(w.readConfig('SystrayContainmentId')); if (!st) return; st.currentConfigGroup = ['General']; var items = String(st.readConfig('extraItems', '')).split(',').filter(function(x) { return x && x !== 'org.kde.plasma.notifications'; }); if (add) items.push('org.kde.plasma.notifications'); st.writeConfig('extraItems', items); }); });";
    }
    readonly property string marker: Config.configDir + "/.plasma-notifications-off"

    function handOver() {
        handoverStatus = "Switching… Plasma's panel will restart for a moment.";
        handover.enable = false;
        handover.running = true;
    }
    function giveBack() {
        handoverStatus = "Giving notifications back to Plasma… the panel will restart for a moment.";
        handover.enable = true;
        handover.running = true;
    }
    Process {
        id: handover
        property bool enable: false
        command: ["sh", "-c", "dbus-send --session --print-reply --dest=org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript string:\"$1\" >/dev/null || exit 2; " + (enable ? "rm -f \"$2\"" : "touch \"$2\"") + "; sleep 1; systemctl --user restart plasma-plasmashell.service 2>/dev/null || { kquitapp6 plasmashell; sleep 1; setsid plasmashell >/dev/null 2>&1 & }", "sh", root.trayScript(enable), root.marker]
        onExited: code => {
            if (code === 2)
                root.handoverStatus = "Plasma didn't accept the change (are your widgets locked?). Use the manual steps below.";
            else
                root.handoverStatus = "";
            ownerTimer.interval = 6000;
            ownerTimer.restart();
        }
    }

    // ---- the server -------------------------------------------------------------
    NotificationServer {
        id: server
        keepOnReload: true
        bodySupported: true
        bodyMarkupSupported: false
        actionsSupported: true
        imageSupported: true
        persistenceSupported: true

        onNotification: n => {
            n.tracked = true;
            root.received(n);
        }
    }

    // History shown in the control centre (newest first): plain copies, so
    // they survive after the notification itself is gone.
    property var history: []
    property int unread: 0

    // Notifications waiting to pop up in the pill, and the one showing now.
    property var queue: []
    property var current: null

    function iconFor(n) {
        if (n.image)
            return n.image;
        const icon = n.appIcon || "";
        if (icon.indexOf("/") === 0 || icon.indexOf("file:") === 0 || icon.indexOf("image:") === 0)
            return icon;
        const name = icon || n.desktopEntry || n.appName.toLowerCase();
        return name ? Quickshell.iconPath(name, true) : "";
    }

    function received(n) {
        const item = {
            id: n.id,
            app: n.appName || "Notification",
            summary: n.summary || "",
            body: n.body || "",
            icon: iconFor(n),
            critical: n.urgency === NotificationUrgency.Critical,
            time: Date.now()
        };
        history = [item].concat(history.filter(h => h.id !== n.id)).slice(0, Config.notifHistory);
        unread++;

        const critical = item.critical;
        if (!Config.notifShowInPill || (PillState.dnd && !critical) || n.transient && PillState.dnd) {
            return;
        }
        // An update of the one on screen: just refresh it.
        if (current && current.id === n.id) {
            showTimer.restart();
            return;
        }
        queue = queue.filter(q => q.id !== n.id).concat([n]);
        n.closed.connect(() => root.forget(n));
        if (!current)
            next();
    }

    function forget(n) {
        queue = queue.filter(q => q !== n);
        if (current === n) {
            current = null;
            next();
        }
    }

    function next() {
        if (queue.length === 0) {
            current = null;
            return;
        }
        current = queue[0];
        queue = queue.slice(1);
        showTimer.restart();
    }

    // Close the one on screen (and tell the app it was dismissed).
    function dismissCurrent() {
        const n = current;
        current = null;
        if (n)
            n.dismiss();
        next();
    }

    // Hide the one on screen without dismissing it (it stays in history).
    function hideCurrent() {
        current = null;
        next();
    }

    function invokeDefault() {
        const n = current;
        if (!n)
            return;
        const def = n.actions.find(a => a.identifier === "default");
        if (def)
            def.invoke();
        dismissCurrent();
    }

    // Show a sample in the pill without going through the notification
    // system (works even while Plasma still handles notifications).
    function showPreview() {
        const sample = {
            id: -1,
            appName: "ArchPill",
            summary: "Hello from ArchPill 👋",
            body: "This is what notifications look like in the pill.",
            image: Quickshell.shellPath("assets/logo.png"),
            appIcon: "",
            desktopEntry: "",
            urgency: 1,
            expireTimeout: -1,
            actions: [],
            dismiss: function () {}
        };
        queue = queue.concat([sample]);
        if (!current)
            next();
    }

    // Test button: a real notification once ArchPill handles them, a preview before that.
    function test() {
        if (active)
            Quickshell.execDetached(["notify-send", "-a", "ArchPill", "-i", Quickshell.shellPath("assets/logo.png"), "Hello from ArchPill 👋", "This is what notifications look like in the pill."]);
        else
            showPreview();
    }

    function clearHistory() {
        history = [];
        unread = 0;
    }
    function removeFromHistory(id) {
        history = history.filter(h => h.id !== id);
    }
    function markRead() {
        unread = 0;
    }

    property bool paused: false // true while the mouse is on the notification
    Timer {
        id: showTimer
        interval: {
            const n = root.current;
            if (!n)
                return Config.notifDuration;
            if (n.expireTimeout > 0)
                return Math.max(2000, Math.min(15000, n.expireTimeout));
            return Config.notifDuration;
        }
        running: !!root.current && !root.paused && root.current.urgency !== NotificationUrgency.Critical
        onTriggered: root.hideCurrent()
    }
}
