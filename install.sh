#!/usr/bin/env bash
# ArchPill installer for Arch Linux + KDE Plasma 6 (Wayland).
#
#   ./install.sh               install packages, copy files, add autostart
#   ./install.sh --no-packages only copy files + autostart (use after editing the code)
#   ./install.sh --no-autostart  don't start ArchPill automatically at login
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
TARGET="$CONFIG_HOME/quickshell/archpill"
USER_CONF_DIR="$CONFIG_HOME/archpill"
AUTOSTART_FILE="$CONFIG_HOME/autostart/archpill.desktop"

# Packages ArchPill needs (most are already on a Plasma install).
PACKAGES=(quickshell qt6-svg qt6-declarative upower pipewire wireplumber)

INSTALL_PACKAGES=1
AUTOSTART=1
for arg in "$@"; do
    case "$arg" in
        --no-packages) INSTALL_PACKAGES=0 ;;
        --no-autostart) AUTOSTART=0 ;;
        -h|--help) sed -n '2,7p' "$0"; exit 0 ;;
        *) echo "Unknown option: $arg"; exit 1 ;;
    esac
done

say()  { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33mwarning:\033[0m %s\n' "$*"; }
die()  { printf '\033[1;31merror:\033[0m %s\n' "$*"; exit 1; }

[[ $EUID -eq 0 ]] && die "Run this as your normal user, not with sudo (it will ask for your password when needed)."
command -v pacman >/dev/null || die "pacman not found - this script is for Arch Linux."

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

# ---- 3. user config ------------------------------------------------------------
mkdir -p "$USER_CONF_DIR"
if [[ ! -f "$USER_CONF_DIR/config.json" ]]; then
    say "Creating your config: $USER_CONF_DIR/config.json"
    cp "$REPO_DIR/config.default.json" "$USER_CONF_DIR/config.json"
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
Exec=$QS_BIN -c archpill -n -d
Icon=preferences-desktop-notification
X-KDE-autostart-phase=2
X-GNOME-Autostart-enabled=true
NoDisplay=true
DESKTOP
else
    rm -f "$AUTOSTART_FILE"
fi

echo
say "Done!"
echo "Start ArchPill now with:"
echo "    qs -c archpill -n -d"
echo "Then move your mouse to the top-centre edge of the screen."
