pragma Singleton

import QtQuick
import Quickshell

// Stopwatch / countdown state (lives here so it survives the control centre closing).
Singleton {
    id: root

    property string mode: "stopwatch" // or "countdown"
    property bool running: false
    property real startedAt: 0
    property real elapsedMs: 0      // stopwatch: time so far (excluding current run)
    property real remainingMs: 0    // countdown: time left (when paused)
    property real target: 0         // countdown: end time while running
    property real now: Date.now()

    readonly property real shownMs: mode === "countdown" ? (running ? Math.max(0, target - now) : remainingMs) : elapsedMs + (running ? now - startedAt : 0)
    readonly property string display: {
        const total = Math.floor(shownMs / 1000);
        const h = Math.floor(total / 3600), m = Math.floor(total % 3600 / 60), s = total % 60;
        const two = n => (n < 10 ? "0" : "") + n;
        return (h > 0 ? h + ":" : "") + two(m) + ":" + two(s);
    }

    function start() {
        if (running)
            return;
        if (mode === "countdown") {
            if (remainingMs <= 0)
                return;
            target = Date.now() + remainingMs;
        } else {
            startedAt = Date.now();
        }
        now = Date.now();
        running = true;
    }
    function pause() {
        if (!running)
            return;
        if (mode === "countdown")
            remainingMs = Math.max(0, target - Date.now());
        else
            elapsedMs += Date.now() - startedAt;
        running = false;
    }
    function reset() {
        running = false;
        elapsedMs = 0;
        remainingMs = 0;
        mode = "stopwatch";
    }
    function countdown(seconds) {
        running = false;
        mode = "countdown";
        remainingMs = seconds * 1000;
        start();
    }

    // Ticks once a second, only while running.
    Timer {
        interval: 1000
        repeat: true
        running: root.running
        onTriggered: {
            root.now = Date.now();
            if (root.mode === "countdown" && root.target - root.now <= 0) {
                root.running = false;
                root.remainingMs = 0;
                Quickshell.execDetached(["notify-send", "-a", "ArchPill", "-i", "chronometer", "Timer finished", "Your countdown is done."]);
            }
        }
    }
}
