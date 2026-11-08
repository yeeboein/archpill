#!/usr/bin/env bash
# ArchPill installer for Arch Linux + KDE Plasma 6 (Wayland).
#
#   ./install.sh               install packages, copy files, add autostart
#   ./install.sh --no-packages only copy files + autostart (use after editing the code)
#   ./install.sh --no-autostart  don't start ArchPill automatically at login
#   ./install.sh --reset-config  back up your config.json and start fresh from the defaults
#   ./install.sh --no-start      don't start ArchPill at the end
#   ./install.sh --fonts         only install a pack of extra free fonts
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
TARGET="$CONFIG_HOME/quickshell/archpill"
USER_CONF_DIR="$CONFIG_HOME/archpill"
AUTOSTART_FILE="$CONFIG_HOME/autostart/archpill.desktop"
APPS_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/applications"
SETTINGS_LAUNCHER="$APPS_DIR/archpill-settings.desktop"
APP_LAUNCHER="$APPS_DIR/archpill.desktop"

# Packages ArchPill needs (most are already on a Plasma install).
PACKAGES=(quickshell qt6-svg qt6-declarative upower pipewire wireplumber networkmanager bluez brightnessctl git libnotify)

INSTALL_PACKAGES=1
AUTOSTART=1
RESET_CONFIG=0
START=1
FONTS_ONLY=0
for arg in "$@"; do
    case "$arg" in
        --no-packages) INSTALL_PACKAGES=0 ;;
        --no-autostart) AUTOSTART=0 ;;
        --reset-config) RESET_CONFIG=1 ;;
        --no-start) START=0 ;;
        --fonts) FONTS_ONLY=1 ;;
        -h|--help) sed -n '2,10p' "$0"; exit 0 ;;
        *) echo "Unknown option: $arg"; exit 1 ;;
    esac
done

say()  { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33mwarning:\033[0m %s\n' "$*"; }
die()  { printf '\033[1;31merror:\033[0m %s\n' "$*"; exit 1; }

[[ $EUID -eq 0 ]] && die "Run this as your normal user, not with sudo (it will ask for your password when needed)."
command -v pacman >/dev/null || die "pacman not found - this script is for Arch Linux."

# ---- extra fonts (./install.sh --fonts) --------------------------------------
# A pack of free fonts from the official repos. Names that don't exist in your
# repos are skipped, so one missing package doesn't stop the rest.
FONT_PACKAGES=(inter-font ttf-jetbrains-mono ttf-fira-sans ttf-fira-code ttf-fira-mono
    ttf-roboto ttf-roboto-mono ttf-ubuntu-font-family ttf-opensans cantarell-fonts
    adobe-source-sans-fonts adobe-source-serif-fonts adobe-source-code-pro-fonts
    ttf-ibm-plex ttf-hack ttf-cascadia-code ttf-liberation ttf-dejavu ttf-croscore
    ttf-anonymous-pro ttf-inconsolata ttf-iosevka-nerd ttf-nerd-fonts-symbols
    otf-monaspace ttf-lato ttf-bitstream-vera gnu-free-fonts ttf-caladea ttf-carlito
    otf-libertinus tex-gyre-fonts ttf-junicode noto-fonts noto-fonts-emoji)
if [[ $FONTS_ONLY -eq 1 ]]; then
    available=()
    for p in "${FONT_PACKAGES[@]}"; do
        pacman -Si "$p" >/dev/null 2>&1 && available+=("$p")
    done
    say "Installing ${#available[@]} font packages"
    sudo pacman -S --needed "${available[@]}"
    fc-cache -f >/dev/null 2>&1 || true
    say "Fonts installed. Restart ArchPill to see them: qs kill -c archpill; QS_APP_ID=archpill qs -c archpill -n -d"
    exit 0
fi

# ---- 1. packages -------------------------------------------------------------
if [[ $INSTALL_PACKAGES -eq 1 ]]; then
    say "Installing packages: ${PACKAGES[*]}"
    if pacman -Si quickshell >/dev/null 2>&1; then
        sudo pacman -S --needed "${PACKAGES[@]}"
    else
        # quickshell isn't in your enabled repos -> use the AUR
        others=()
        for p in "${PACKAGES[@]}"; do [[ $p != quickshell ]] && others+=("$p"); done
        sudo pacman -S --needed "${others[@]}"
        if pacman -Qi quickshell >/dev/null 2>&1 || pacman -Qi quickshell-git >/dev/null 2>&1; then
            say "quickshell is already installed."
        elif command -v paru >/dev/null; then
            paru -S --needed quickshell
        elif command -v yay >/dev/null; then
            yay -S --needed quickshell
        else
            die "quickshell is not in the official repos and no AUR helper (yay/paru) was found.
Install yay first:
  sudo pacman -S --needed git base-devel
  git clone https://aur.archlinux.org/yay-bin.git && cd yay-bin && makepkg -si
then run ./install.sh again."
        fi
    fi
fi

QS_BIN="$(command -v qs || command -v quickshell || true)"
[[ -n "$QS_BIN" ]] || die "quickshell is not installed (no 'qs' command found)."

# ---- 2. copy files -------------------------------------------------------------
say "Copying ArchPill to $TARGET"
mkdir -p "$TARGET"
# Replace only our own files; tar keeps the folder layout.
find "$TARGET" -mindepth 1 -delete
tar -C "$REPO_DIR" \
    --exclude=.git --exclude='*.sh' --exclude=README.md --exclude=LICENSE --exclude=docs \
    -cf - . | tar -C "$TARGET" -xf -

# Remember where this copy came from, so the in-app updater can `git pull` it.
echo "$REPO_DIR" > "$TARGET/.archpill-source"

# ---- 3. user config ------------------------------------------------------------
mkdir -p "$USER_CONF_DIR"
if [[ $RESET_CONFIG -eq 1 && -f "$USER_CONF_DIR/config.json" ]]; then
    backup="$USER_CONF_DIR/config.json.backup-$(date +%Y%m%d-%H%M%S)"
    mv "$USER_CONF_DIR/config.json" "$backup"
    say "Old config saved as $backup"
fi
if [[ ! -f "$USER_CONF_DIR/config.json" ]]; then
    # Start empty: everything comes from config.default.json, and only the
    # settings you change get stored here (so you get new defaults on updates).
    say "Creating your config: $USER_CONF_DIR/config.json"
    echo "{}" > "$USER_CONF_DIR/config.json"
else
    say "Keeping your existing config: $USER_CONF_DIR/config.json"
fi

# ---- 4. autostart --------------------------------------------------------------
if [[ $AUTOSTART -eq 1 ]]; then
    say "Adding autostart entry: $AUTOSTART_FILE"
    mkdir -p "$(dirname "$AUTOSTART_FILE")"
    cat > "$AUTOSTART_FILE" <<DESKTOP
[Desktop Entry]
Type=Application
Name=ArchPill
Comment=Dynamic Island-style pill for Plasma
Exec=env QS_APP_ID=archpill $QS_BIN -c archpill -n -d
Icon=$TARGET/assets/logo.png
X-KDE-autostart-phase=2
X-GNOME-Autostart-enabled=true
NoDisplay=true
DESKTOP
else
    rm -f "$AUTOSTART_FILE"
fi

# ---- 5. "ArchPill Settings" in the app menu ------------------------------------
say "Adding 'ArchPill Settings' to your app menu"
mkdir -p "$APPS_DIR"
cat > "$SETTINGS_LAUNCHER" <<DESKTOP
[Desktop Entry]
Type=Application
Name=ArchPill Settings
Comment=Customise your ArchPill
Exec=sh -c '$QS_BIN -c archpill ipc call archpill openSettings || (QS_APP_ID=archpill $QS_BIN -c archpill -n -d; sleep 2; $QS_BIN -c archpill ipc call archpill openSettings)'
Icon=$TARGET/assets/logo.png
Categories=Settings;DesktopSettings;
Keywords=pill;island;quickshell;control centre;
DESKTOP

# "ArchPill" app entry. Besides starting ArchPill from the menu, it gives
# ArchPill's windows their name and logo (app id "archpill", set through
# QS_APP_ID; needs Quickshell 0.3 or newer) instead of Quickshell's.
cat > "$APP_LAUNCHER" <<DESKTOP
[Desktop Entry]
Type=Application
Name=ArchPill
Comment=Dynamic Island-style pill for Plasma (start / restart)
Exec=sh -c '$QS_BIN kill -c archpill >/dev/null 2>&1; sleep 0.5; QS_APP_ID=archpill exec $QS_BIN -c archpill -n -d'
Icon=$TARGET/assets/logo.png
StartupWMClass=archpill
Categories=Utility;
Keywords=pill;island;quickshell;
DESKTOP
update-desktop-database "$APPS_DIR" >/dev/null 2>&1 || true

echo
say "Done!"
if [[ $START -eq 1 && -n "${WAYLAND_DISPLAY:-}" ]]; then
    # Restart so the new files are used. The first time, a welcome tour pops up.
    "$QS_BIN" kill -c archpill >/dev/null 2>&1 || true
    sleep 0.5
    QS_APP_ID=archpill "$QS_BIN" -c archpill -n -d >/dev/null 2>&1 || true
    echo "ArchPill is running. Move your mouse to the top-centre edge of the screen."
else
    echo "Start ArchPill with:"
    echo "    QS_APP_ID=archpill qs -c archpill -n -d   (or: app menu -> ArchPill)"
fi
