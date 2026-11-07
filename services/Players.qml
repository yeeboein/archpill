pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Mpris
import qs

// Picks the one media player ArchPill shows.
//
// Rules:
//  - players with no song title are ignored (this hides empty/junk players)
//  - players matching anything in `media.ignoredPlayers` are ignored
//  - Brave/Chrome "Plasma Integration" creates a second copy of the browser's
//    player (plasma-browser-integration). If both copies show the same song,
//    the duplicate is dropped.
//  - the player matching `media.preferredPlayer` (default "spotify") wins,
//    unless `media.preferPlaying` is true and another player is playing
//  - otherwise: whatever is playing, else the first one
Singleton {
    id: root

    readonly property var candidates: filterPlayers(Mpris.players.values, Config.ignoredPlayers)
    // A player you picked by hand in the music dropdown (wins until it goes away).
    property var chosen: null
    readonly property var active: (chosen && candidates.indexOf(chosen) !== -1) ? chosen : pick(candidates, Config.preferredPlayer, Config.preferPlaying)
    readonly property bool hasPlayer: active !== null

    function nameOf(p) {
        return ((p.identity || "") + " " + (p.desktopEntry || "") + " " + (p.dbusName || "")).toLowerCase();
    }

    function isBrowserProxy(p) {
        return (p.dbusName || "").toLowerCase().indexOf("plasma-browser-integration") !== -1;
    }

    function filterPlayers(list, ignored) {
        const out = [];
        for (let i = 0; i < list.length; i++) {
            const p = list[i];
            if (!p || !p.trackTitle)
                continue;
            const n = nameOf(p);
            let skip = false;
            for (let j = 0; j < (ignored || []).length; j++) {
                const ig = String(ignored[j] || "").toLowerCase();
                if (ig && n.indexOf(ig) !== -1) {
                    skip = true;
                    break;
                }
            }
            if (!skip)
                out.push(p);
        }
        // Drop plasma-browser-integration copies of a song another player already shows.
        return out.filter(p => !(isBrowserProxy(p) && out.some(o => o !== p && !isBrowserProxy(o) && o.trackTitle === p.trackTitle)));
    }

    function pick(list, preferred, preferPlaying) {
        if (list.length === 0)
            return null;
        const playing = list.find(p => p.isPlaying) || null;
        const pref = preferred ? (list.find(p => nameOf(p).indexOf(String(preferred).toLowerCase()) !== -1) || null) : null;
        if (pref && !(preferPlaying && playing && !pref.isPlaying))
            return pref;
        return playing || list[0];
    }

    function choose(p) {
        chosen = p;
    }

    function displayName(p) {
        return p ? (p.identity || p.desktopEntry || "Player") : "";
    }

    function togglePlaying() {
        if (active && active.canTogglePlaying)
            active.togglePlaying();
    }
    function next() {
        if (active && active.canGoNext)
            active.next();
    }
    function previous() {
        if (active && active.canGoPrevious)
            active.previous();
    }
}
