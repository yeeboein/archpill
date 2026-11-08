#!/usr/bin/env bash
# ArchPill installer for Arch Linux. Works with KDE Plasma, Hyprland, Sway,
# niri, river, Wayfire, labwc, COSMIC and (best effort, X11) Xfce/Cinnamon/MATE.
# GNOME can't show it: GNOME doesn't let apps put panels over windows.
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
PACKAGES=(quickshell qt6-svg qt6-declarative upower pipewire wireplumber brightnessctl git libnotify)

# Which desktop are we on?
detect_desktop() {
    local d="${XDG_CURRENT_DESKTOP:-}:${XDG_SESSION_DESKTOP:-}"
    d="${d,,}"
    if [[ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" || $d == *hyprland* ]]; then echo hyprland
    elif [[ -n "${NIRI_SOCKET:-}" || $d == *niri* ]]; then echo niri
    elif [[ -n "${SWAYSOCK:-}" || $d == *sway* ]]; then echo sway
    elif [[ $d == *kde* || $d == *plasma* ]]; then echo kde
    elif [[ $d == *gnome* || $d == *ubuntu* ]]; then echo gnome
    elif [[ $d == *cosmic* ]]; then echo cosmic
    elif [[ $d == *xfce* ]]; then echo xfce
    elif [[ $d == *cinnamon* ]]; then echo cinnamon
    elif [[ $d == *river* ]]; then echo river
    elif [[ $d == *wayfire* ]]; then echo wayfire
    elif [[ $d == *labwc* ]]; then echo labwc
    else echo other; fi
}
DESKTOP_ENV="$(detect_desktop)"

# Helpers ArchPill uses outside KDE (screenshots, clipboard history, night light).
# Only installed if they exist in your repos; nothing breaks without them.
EXTRA_PACKAGES=()
case "$DESKTOP_ENV" in
    kde) ;;
    hyprland) EXTRA_PACKAGES=(grim slurp wl-clipboard cliphist hyprsunset networkmanager bluez bluez-utils) ;;
    *) EXTRA_PACKAGES=(grim slurp wl-clipboard cliphist wlsunset networkmanager bluez bluez-utils) ;;
esac

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
# A big pack of free fonts. Names that don't exist are skipped, so one
# missing package doesn't stop the rest.
FONT_PACKAGES=(
    # everyday sans / serif
    inter-font ttf-roboto ttf-opensans ttf-ubuntu-font-family cantarell-fonts ttf-lato
    ttf-fira-sans adobe-source-sans-fonts adobe-source-serif-fonts ttf-ibm-plex
    ttf-liberation ttf-dejavu ttf-croscore ttf-droid ttf-bitstream-vera gnu-free-fonts
    ttf-caladea ttf-carlito otf-libertinus ttf-linux-libertine tex-gyre-fonts ttf-junicode
    ttf-gentium-plus otf-overpass otf-latin-modern noto-fonts noto-fonts-extra noto-fonts-emoji
    # JetBrains Mono (all versions) and other coding fonts
    ttf-jetbrains-mono ttf-jetbrains-mono-nerd ttf-fira-code ttf-fira-mono ttf-roboto-mono
    adobe-source-code-pro-fonts ttf-hack ttf-cascadia-code otf-cascadia-code ttf-inconsolata
    ttf-anonymous-pro otf-monaspace ttf-iosevka-nerd terminus-font
    # Nerd Fonts (coding fonts with icons built in)
    ttf-nerd-fonts-symbols ttf-nerd-fonts-symbols-mono ttf-firacode-nerd ttf-hack-nerd
    ttf-meslo-nerd ttf-sourcecodepro-nerd ttf-ubuntu-nerd ttf-ubuntu-mono-nerd ttf-dejavu-nerd
    ttf-cascadia-code-nerd ttf-cascadia-mono-nerd ttf-victor-mono-nerd ttf-mononoki-nerd
    ttf-iosevkaterm-nerd ttf-terminus-nerd ttf-agave-nerd ttf-arimo-nerd ttf-cousine-nerd
    ttf-noto-nerd ttf-roboto-mono-nerd ttf-space-mono-nerd ttf-go-nerd ttf-lilex-nerd
    ttf-martian-mono-nerd ttf-monofur-nerd ttf-monoid-nerd ttf-mplus-nerd ttf-profont-nerd
    ttf-sharetech-mono-nerd ttf-tinos-nerd ttf-bitstream-vera-mono-nerd ttf-liberation-mono-nerd
    otf-aurulent-nerd otf-codenewroman-nerd otf-firamono-nerd otf-geist-mono-nerd
    otf-hasklig-nerd otf-hermit-nerd otf-overpass-nerd otf-droid-nerd
    # fun & friendly (Comic Shanns, OpenDyslexic)
    otf-comicshanns-nerd otf-opendyslexic-nerd
    # symbols & dingbats (free Wingdings-style fonts)
    urw-base35-fonts gsfonts otf-font-awesome ttf-font-awesome ttf-joypixels
)
# From the AUR (needs yay or paru): Comic Sans MS + Webdings + Impact, Arial,
# Times New Roman, Georgia, Verdana... (ttf-ms-fonts), more comic and
# Wingdings-style fonts, and popular Google fonts.
AUR_FONT_PACKAGES=(
    ttf-ms-fonts ttf-comic-neue ttf-comic-mono-git otf-comicshanns ttf-symbola
    ttf-material-design-icons-desktop-git ttf-poppins ttf-montserrat ttf-raleway
    ttf-oswald ttf-nunito ttf-quicksand ttf-lexend ttf-work-sans ttf-manrope
    ttf-merriweather ttf-playfair-display ttf-bebas-neue ttf-space-grotesk ttf-rubik
    ttf-karla ttf-barlow ttf-josefin-sans ttf-pacifico ttf-lobster ttf-dm-sans
    ttf-outfit ttf-archivo ttf-mulish ttf-atkinson-hyperlegible ttf-borg-sans-mono
)
if [[ $FONTS_ONLY -eq 1 ]]; then
    say "Looking up ${#FONT_PACKAGES[@]} font packages in your repos…"
    available=()
    for p in "${FONT_PACKAGES[@]}"; do
        pacman -Si "$p" >/dev/null 2>&1 && available+=("$p")
    done
    say "Installing ${#available[@]} font packages from the official repos"
    sudo pacman -S --needed "${available[@]}" || warn "Some fonts failed to install."

    helper="$(command -v paru || command -v yay || true)"
    if [[ -n "$helper" ]]; then
        say "Looking up ${#AUR_FONT_PACKAGES[@]} font packages in the AUR (Comic Sans, Webdings, Google fonts…)"
        aur=()
        for p in "${AUR_FONT_PACKAGES[@]}"; do
            pacman -Qq "$p" >/dev/null 2>&1 && continue
            "$helper" -Si "$p" >/dev/null 2>&1 && aur+=("$p")
        done
        if [[ ${#aur[@]} -gt 0 ]]; then
            say "Installing ${#aur[@]} AUR font packages"
            "$helper" -S --needed "${aur[@]}" || warn "Some AUR fonts failed to install."
        fi
    else
        warn "No AUR helper (yay/paru) found, so Comic Sans, Webdings and the Google fonts were skipped."
        echo "  Install yay, then run ./install.sh --fonts again:"
        echo "    sudo pacman -S --needed git base-devel"
        echo "    git clone https://aur.archlinux.org/yay-bin.git && cd yay-bin && makepkg -si"
    fi

    echo
    echo "Note: Wingdings itself is a Windows-only font and can't be downloaded freely."
    echo "You now have Webdings and free symbol fonts instead (Dingbats, Symbola, Font Awesome, Noto Symbols, Nerd Font symbols)."
    fc-cache -f >/dev/null 2>&1 || true
    say "Fonts installed. Restart ArchPill (Settings → Appearance → Restart ArchPill) to see them."
    exit 0
fi

say "Desktop: $DESKTOP_ENV"
if [[ $DESKTOP_ENV == gnome ]]; then
    warn "GNOME doesn't allow apps to place panels over other windows (no 'layer-shell'),"
    warn "so ArchPill's pill can't appear on GNOME. It works on KDE Plasma, Hyprland, Sway, niri and others."
    read -r -p "Install anyway? [y/N] " ans
    [[ "${ans,,}" == "y" ]] || exit 1
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

if [[ $INSTALL_PACKAGES -eq 1 && ${#EXTRA_PACKAGES[@]} -gt 0 ]]; then
    extras=()
    for p in "${EXTRA_PACKAGES[@]}"; do
        pacman -Qq "$p" >/dev/null 2>&1 && continue
        pacman -Si "$p" >/dev/null 2>&1 && extras+=("$p")
    done
    if [[ ${#extras[@]} -gt 0 ]]; then
        say "Installing helpers for $DESKTOP_ENV: ${extras[*]}"
        sudo pacman -S --needed "${extras[@]}" || warn "Some helpers failed to install (ArchPill still works)."
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
# KDE, GNOME, Xfce, Cinnamon, COSMIC... use ~/.config/autostart.
# Hyprland, Sway and niri don't, so a line is added to their config instead
# (marked "archpill-autostart" so uninstall.sh can remove it).
START_CMD="env QS_APP_ID=archpill $QS_BIN -c archpill -n -d"
add_line() { # file, line, comment-prefix
    local f="$1" line="$2" c="${3:-#}"
    [[ -f "$f" ]] || return 1
    grep -q "archpill-autostart" "$f" && { say "Autostart already in $f"; return 0; }
    printf '\n%s %s\n%s\n' "$c" "archpill-autostart (added by ArchPill's install.sh)" "$line" >> "$f"
    say "Added autostart to $f"
}
if [[ $AUTOSTART -eq 1 ]]; then
    say "Adding autostart entry: $AUTOSTART_FILE"
    mkdir -p "$(dirname "$AUTOSTART_FILE")"
    cat > "$AUTOSTART_FILE" <<DESKTOP
[Desktop Entry]
Type=Application
Name=ArchPill
Comment=Dynamic Island-style pill
Exec=$START_CMD
Icon=$TARGET/assets/logo.png
X-KDE-autostart-phase=2
X-GNOME-Autostart-enabled=true
NoDisplay=true
DESKTOP
    case "$DESKTOP_ENV" in
        hyprland) add_line "$CONFIG_HOME/hypr/hyprland.conf" "exec-once = $START_CMD" || warn "Add 'exec-once = $START_CMD' to your Hyprland config to start ArchPill at login." ;;
        sway) add_line "$CONFIG_HOME/sway/config" "exec $START_CMD" || warn "Add 'exec $START_CMD' to your Sway config to start ArchPill at login." ;;
        niri) add_line "$CONFIG_HOME/niri/config.kdl" "spawn-at-startup \"sh\" \"-c\" \"$START_CMD\"" "//" || warn "Add a spawn-at-startup line for ArchPill to your niri config." ;;
        river|wayfire|labwc|other) warn "If your desktop doesn't run ~/.config/autostart, start ArchPill at login with: $START_CMD" ;;
    esac
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
if [[ $START -eq 1 && ( -n "${WAYLAND_DISPLAY:-}" || -n "${DISPLAY:-}" ) ]]; then
    # Restart so the new files are used. The first time, a welcome tour pops up.
    "$QS_BIN" kill -c archpill >/dev/null 2>&1 || true
    sleep 0.5
    QS_APP_ID=archpill "$QS_BIN" -c archpill -n -d >/dev/null 2>&1 || true
    echo "ArchPill is running. Move your mouse to the top-centre edge of the screen."
else
    echo "Start ArchPill with:"
    echo "    QS_APP_ID=archpill qs -c archpill -n -d   (or: app menu -> ArchPill)"
fi
