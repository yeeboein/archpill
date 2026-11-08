import QtQuick
import qs.components
import qs.services

// Check for / install ArchPill updates from GitHub.
Tile {
    icon: "download"
    title: Updater.available ? "Update ArchPill" : "ArchPill Updates"
    subtitle: Updater.status === "checking" ? "Checking…" : Updater.status === "updating" ? "Updating…" : Updater.status === "error" ? "Error - see Settings" : Updater.status === "norepo" ? "Not installed from git" : Updater.available ? Updater.behind + " new - click to update" : Updater.lastCheck > 0 ? "Up to date ✓" : "Click to check"
    active: Updater.available
    onClicked: Updater.available ? Updater.update() : Updater.check()
}
