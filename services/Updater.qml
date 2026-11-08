pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs

// Checks GitHub for a newer ArchPill and installs it.
//
// install.sh writes the folder you cloned ArchPill into (e.g. ~/archpill) to
// .archpill-source. Checking = `git fetch` there and counting new commits.
// Updating = `git pull` + `./install.sh --no-packages` (run detached), which
// restarts ArchPill on the new version.
// Checks a minute after start, then every "updates.checkHours" hours.
Singleton {
    id: root

    property string repo: ""
    property int behind: 0              // how many updates are waiting
    property var changes: []            // their one-line descriptions
    property string remoteHash: ""
    property string status: "idle"      // idle, checking, updating, error, norepo
    property string error: ""
    property real lastCheck: 0
    readonly property bool available: behind > 0
    readonly property string logFile: (Quickshell.env("XDG_CACHE_HOME") || (Quickshell.env("HOME") + "/.cache")) + "/archpill-update.log"

    // Where the git copy is: from install.sh, or ~/archpill as a fallback.
    FileView {
        path: Quickshell.shellPath(".archpill-source")
        blockLoading: true
        onLoaded: root.repo = text().trim()
        onLoadFailed: root.repo = (Quickshell.env("HOME") || "") + "/archpill"
    }

    function check() {
        if (checker.running || status === "updating" || !repo)
            return;
        status = "checking";
        error = "";
        checker.running = true;
    }

    function update() {
        if (status === "updating" || !repo)
            return;
        status = "updating";
        error = "";
        notify("Updating ArchPill…", "It will restart by itself in a moment.");
        // Fully detached (setsid): install.sh restarts ArchPill, and a child
        // process would be killed together with the old ArchPill.
        const script = "cd \"$1\" || exit 1; { echo; echo \"== $(date)\"; git pull --ff-only && ./install.sh --no-packages; } >> \"$2\" 2>&1 "
            + "&& notify-send -a ArchPill -i \"$3\" 'ArchPill updated' 'You are on the latest version.' "
            + "|| notify-send -a ArchPill -i \"$3\" 'ArchPill update failed' \"Details are in $2\"";
        Quickshell.execDetached(["setsid", "sh", "-c", script, "sh", repo, logFile, Quickshell.shellPath("assets/logo.png")]);
        stuckTimer.restart();
    }

    // If we're still running a while later, the update didn't restart us
    // (e.g. git pull failed). Let the user try again.
    Timer {
        id: stuckTimer
        interval: 90 * 1000
        onTriggered: {
            if (root.status === "updating") {
                root.status = "error";
                root.error = "Update didn't finish - see " + root.logFile;
            }
        }
    }

    function notify(title, body) {
        Quickshell.execDetached(["notify-send", "-a", "ArchPill", "-i", Quickshell.shellPath("assets/logo.png"), title, body]);
    }

    // Prints: <count>\n<remote hash>\n<one line per new commit>
    Process {
        id: checker
        command: ["sh", "-c", "cd \"$1\" && git rev-parse --is-inside-work-tree >/dev/null 2>&1 || exit 3; git fetch --quiet 2>&1 >/dev/null || exit 4; git rev-list --count HEAD..@{u} && git rev-parse @{u} && git log --format=%s HEAD..@{u} | head -n 8", "sh", root.repo]
        stdout: StdioCollector {
            id: checkOut
        }
        stderr: StdioCollector {
            id: checkErr
        }
        onExited: code => {
            root.lastCheck = Date.now();
            if (code === 3) {
                root.status = "norepo";
                root.behind = 0;
                return;
            }
            if (code !== 0) {
                root.status = "error";
                root.error = code === 4 ? "Couldn't reach GitHub (offline?)" : (checkErr.text.trim() || "git failed");
                return;
            }
            const lines = checkOut.text.trim().split("\n");
            root.behind = parseInt(lines[0]) || 0;
            const hash = (lines[1] || "").trim();
            root.changes = lines.slice(2).filter(l => l.trim() !== "");
            root.status = "idle";
            // Tell the user once per new version.
            if (root.behind > 0 && hash !== root.remoteHash && Config.updateNotify && hash !== Config.get("updates.notified", "")) {
                root.notify("ArchPill update available", root.behind + (root.behind === 1 ? " update" : " updates") + " ready. Open the control centre and press Update.");
                Config.setValue("updates.notified", hash);
            }
            root.remoteHash = hash;
        }
    }

    Timer {
        interval: 60 * 1000
        running: Config.updateAutoCheck
        onTriggered: root.check()
    }
    Timer {
        interval: Math.max(1, Config.updateCheckHours) * 3600 * 1000
        repeat: true
        running: Config.updateAutoCheck
        onTriggered: root.check()
    }
}
