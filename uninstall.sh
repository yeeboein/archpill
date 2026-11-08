#!/usr/bin/env bash
# Removes ArchPill: stops it, deletes its files and the autostart entry.
# Your settings (~/.config/archpill) are only removed if you say yes.
set -euo pipefail

CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
TARGET="$CONFIG_HOME/quickshell/archpill"
USER_CONF_DIR="$CONFIG_HOME/archpill"
AUTOSTART_FILE="$CONFIG_HOME/autostart/archpill.desktop"

say() { printf '\033[1;34m==>\033[0m %s\n' "$*"; }

[[ $EUID -eq 0 ]] && { echo "Run this as your normal user, not with sudo."; exit 1; }

say "Stopping ArchPill"
if command -v qs >/dev/null; then
    qs kill -c archpill >/dev/null 2>&1 || true
fi
pkill -f "quickshell.*-c archpill|qs -c archpill" >/dev/null 2>&1 || true

# Turn Plasma's volume popup back on if ArchPill turned it off.
if [[ -f "$USER_CONF_DIR/.plasma-volume-osd-off" ]]; then
    say "Turning Plasma's volume popup back on"
    kwriteconfig6 --notify --file plasmaparc --group General --key VolumeOsd true || true
    kwriteconfig6 --notify --file plasmaparc --group General --key MuteOsd true || true
    rm -f "$USER_CONF_DIR/.plasma-volume-osd-off"
fi

say "Removing $AUTOSTART_FILE"
rm -f "$AUTOSTART_FILE"
rm -f "${XDG_DATA_HOME:-$HOME/.local/share}/applications/archpill-settings.desktop"
rm -f "${XDG_DATA_HOME:-$HOME/.local/share}/applications/archpill.desktop"

# Remove the autostart lines install.sh added for Hyprland / Sway / niri.
for f in "$CONFIG_HOME/hypr/hyprland.conf" "$CONFIG_HOME/sway/config" "$CONFIG_HOME/niri/config.kdl"; do
    if [[ -f "$f" ]] && grep -q "archpill-autostart" "$f"; then
        say "Removing ArchPill autostart from $f"
        # delete the marker comment and the line after it
        sed -i '/archpill-autostart/{N;d;}' "$f"
    fi
done

say "Removing $TARGET"
rm -rf "$TARGET"

if [[ -d "$USER_CONF_DIR" ]]; then
    read -r -p "Also delete your ArchPill settings in $USER_CONF_DIR? [y/N] " ans
    if [[ "${ans,,}" == "y" ]]; then
        rm -rf "$USER_CONF_DIR"
        say "Settings deleted."
    else
        say "Settings kept."
    fi
fi

say "ArchPill removed. Packages (quickshell etc.) were left installed;"
echo "    remove them with:  sudo pacman -Rs quickshell"
