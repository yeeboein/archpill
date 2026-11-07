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
