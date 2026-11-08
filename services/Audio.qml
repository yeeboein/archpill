pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Pipewire
import qs

// Default speaker/headphone output from PipeWire.
Singleton {
    id: root

    readonly property var sink: Pipewire.defaultAudioSink
    readonly property bool ready: !!sink && sink.ready && !!sink.audio
    readonly property real volume: ready ? sink.audio.volume : 0
    readonly property bool muted: ready ? sink.audio.muted : false
    readonly property int percent: Math.round(volume * 100)

    // Tell the pill when the volume or mute changes (from keys, the panel,
    // apps...). Ignored for a moment after the output device changes, so
    // plugging in headphones doesn't flash the popup.
    onVolumeChanged: announce()
    onMutedChanged: announce()
    onSinkChanged: settle.restart()
    onReadyChanged: settle.restart()
    function announce() {
        if (ready && !settle.running && Config.osdEnabled)
            PillState.showOsd("volume");
    }
    Timer {
        id: settle
        interval: 1500
        running: true
    }

    function setVolume(v) {
        if (!ready)
            return;
        const max = Math.max(1, Config.maxVolume) / 100;
        sink.audio.volume = Math.max(0, Math.min(max, v));
        if (sink.audio.muted && v > 0)
            sink.audio.muted = false;
    }

    function changeBy(steps) {
        setVolume(volume + steps * Config.volumeStep / 100);
    }

    function toggleMute() {
        if (ready)
            sink.audio.muted = !sink.audio.muted;
    }

    // Microphone
    readonly property var source: Pipewire.defaultAudioSource
    readonly property bool micReady: !!source && source.ready && !!source.audio
    readonly property bool micMuted: micReady ? source.audio.muted : false
    function toggleMic() {
        if (micReady)
            source.audio.muted = !source.audio.muted;
    }

    // Pipewire only fills in volume data for nodes that are "tracked".
    PwObjectTracker {
        objects: [root.sink, root.source].filter(o => !!o)
    }
}
