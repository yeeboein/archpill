pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs

// Works out which desktop you're on (KDE, Hyprland, Sway, niri, GNOME, ...)
// and which helper programs are installed, then picks the right command for
// things like screenshots, locking, logging out, the app launcher or the
// terminal. Widgets ask this service instead of hard-coding KDE tools.
Singleton {
    id: root

    // ---- which desktop ---------------------------------------------------------
    readonly property string rawName: ((Quickshell.env("XDG_CURRENT_DESKTOP") || "") + ":" + (Quickshell.env("XDG_SESSION_DESKTOP") || "")).toLowerCase()
    readonly property string de: {
        if (Quickshell.env("HYPRLAND_INSTANCE_SIGNATURE") || rawName.indexOf("hyprland") !== -1)
            return "hyprland";
        if (Quickshell.env("NIRI_SOCKET") || rawName.indexOf("niri") !== -1)
            return "niri";
        if (Quickshell.env("SWAYSOCK") || rawName.indexOf("sway") !== -1)
            return "sway";
        if (rawName.indexOf("kde") !== -1 || rawName.indexOf("plasma") !== -1)
            return "kde";
        if (rawName.indexOf("gnome") !== -1 || rawName.indexOf("ubuntu") !== -1)
            return "gnome";
        if (rawName.indexOf("cosmic") !== -1)
            return "cosmic";
        if (rawName.indexOf("xfce") !== -1)
            return "xfce";
        if (rawName.indexOf("cinnamon") !== -1 || rawName.indexOf("x-cinnamon") !== -1)
            return "cinnamon";
        if (rawName.indexOf("river") !== -1)
            return "river";
        if (rawName.indexOf("wayfire") !== -1)
            return "wayfire";
        if (rawName.indexOf("labwc") !== -1)
            return "labwc";
        return "other";
    }
    readonly property string niceName: ({
            "kde": "KDE Plasma",
            "hyprland": "Hyprland",
            "niri": "niri",
            "sway": "Sway",
            "gnome": "GNOME",
            "cosmic": "COSMIC",
            "xfce": "Xfce",
            "cinnamon": "Cinnamon",
            "river": "river",
            "wayfire": "Wayfire",
            "labwc": "labwc"
        })[de] || "your desktop"
    readonly property bool isKde: de === "kde"
    readonly property bool isGnome: de === "gnome"
    readonly property bool wayland: (Quickshell.env("XDG_SESSION_TYPE") || "") === "wayland" || !!Quickshell.env("WAYLAND_DISPLAY")

    // ---- which helper programs are installed -----------------------------------
    property var have: ({})
    readonly property var probeList: ["spectacle", "grim", "slurp", "wl-copy", "cliphist", "hyprshot", "gnome-screenshot", "flameshot", "wf-recorder", "krunner", "fuzzel", "wofi", "rofi", "anyrun", "walker", "tofi", "plasma-emojier", "bemoji", "smile", "konsole", "kitty", "alacritty", "foot", "wezterm", "ghostty", "gnome-terminal", "kgx", "xfce4-terminal", "systemsettings", "gnome-control-center", "nm-connection-editor", "blueman-manager", "pavucontrol", "pwvucontrol", "plasma-systemmonitor", "gnome-system-monitor", "btop", "htop", "hyprsunset", "wlsunset", "gammastep", "hyprlock", "swaylock", "gtklock", "gsettings", "kwriteconfig6", "plasma-apply-colorscheme", "nwg-look", "wdisplays", "nwg-displays"]
    function has(cmd) {
        return !!have[cmd];
    }
    function first(list) {
        for (let i = 0; i < list.length; i++)
            if (has(list[i]))
                return list[i];
        return "";
    }

    Process {
        running: true
        command: ["sh", "-c", "for c in \"$@\"; do command -v \"$c\" >/dev/null 2>&1 && echo \"$c\"; done", "sh"].concat(root.probeList)
        stdout: StdioCollector {
            onStreamFinished: {
                const h = {};
                text.split("\n").forEach(l => {
                    if (l.trim())
                        h[l.trim()] = true;
                });
                root.have = h;
                console.info("[archpill] desktop: " + root.niceName + " (" + root.de + ")");
            }
        }
    }

    // ---- terminal ----------------------------------------------------------------
    // The program to use, plus how to make it run a command.
    readonly property string terminal: {
        const chosen = Config.terminal;
        if (chosen && chosen !== "auto" && (has(chosen) || Object.keys(have).length === 0))
            return chosen;
        const env = Quickshell.env("TERMINAL") || "";
        if (env)
            return env;
        return first(isKde ? ["konsole", "kitty", "alacritty", "foot", "wezterm", "ghostty"] : ["kitty", "foot", "alacritty", "wezterm", "ghostty", "konsole", "gnome-terminal", "kgx", "xfce4-terminal"]) || "xterm";
    }
    // Command list that opens the terminal running `args`.
    function inTerminal(args) {
        const t = terminal;
        const base = t.split("/").pop();
        if (base === "gnome-terminal" || base === "kgx")
            return [t, "--"].concat(args);
        if (base === "wezterm")
            return [t, "start", "--"].concat(args);
        if (base === "kitty" || base === "foot" || base === "ghostty")
            return [t].concat(args);
        return [t, "-e"].concat(args);
    }

    // ---- actions -------------------------------------------------------------------
    // Returns the command for an action on this desktop, or [] if there's no
    // way to do it here (the widget is then hidden from the catalogue).
    function cmd(action) {
        switch (action) {
        case "screenshot":
            if (has("spectacle"))
                return ["spectacle", "-r"];
            if (has("hyprshot"))
                return ["hyprshot", "-m", "region"];
            if (has("grim") && has("slurp"))
                return ["sh", "-c", "f=\"$(xdg-user-dir PICTURES 2>/dev/null || echo $HOME)/Screenshot_$(date +%F_%H-%M-%S).png\"; grim -g \"$(slurp)\" \"$f\" && (command -v wl-copy >/dev/null && wl-copy < \"$f\"; notify-send -a ArchPill 'Screenshot saved' \"$f\")"];
            if (has("gnome-screenshot"))
                return ["gnome-screenshot", "-a"];
            if (has("flameshot"))
                return ["flameshot", "gui"];
            return [];
        case "screenshotfull":
            if (has("spectacle"))
                return ["spectacle", "-f"];
            if (has("hyprshot"))
                return ["hyprshot", "-m", "output"];
            if (has("grim"))
                return ["sh", "-c", "f=\"$(xdg-user-dir PICTURES 2>/dev/null || echo $HOME)/Screenshot_$(date +%F_%H-%M-%S).png\"; grim \"$f\" && (command -v wl-copy >/dev/null && wl-copy < \"$f\"; notify-send -a ArchPill 'Screenshot saved' \"$f\")"];
            if (has("gnome-screenshot"))
                return ["gnome-screenshot"];
            if (has("flameshot"))
                return ["flameshot", "full"];
            return [];
        case "record":
            if (has("spectacle"))
                return ["spectacle", "--record", "r"];
            if (has("wf-recorder") && has("slurp"))
                return ["sh", "-c", "pkill -INT wf-recorder && exit; f=\"$(xdg-user-dir VIDEOS 2>/dev/null || echo $HOME)/Recording_$(date +%F_%H-%M-%S).mp4\"; notify-send -a ArchPill 'Recording' 'Press the Screen Recording button again to stop.'; wf-recorder -g \"$(slurp)\" -f \"$f\" && notify-send -a ArchPill 'Recording saved' \"$f\""];
            return [];
        case "search":
            if (has("krunner"))
                return ["krunner"];
            if (has("fuzzel"))
                return ["fuzzel"];
            if (has("walker"))
                return ["walker"];
            if (has("anyrun"))
                return ["anyrun"];
            if (has("wofi"))
                return ["wofi", "--show", "drun"];
            if (has("rofi"))
                return ["rofi", "-show", "drun"];
            if (has("tofi"))
                return ["sh", "-c", "$(tofi-drun)"];
            return [];
        case "emoji":
            if (has("plasma-emojier"))
                return ["plasma-emojier"];
            if (has("smile"))
                return ["smile"];
            if (has("bemoji"))
                return ["bemoji"];
            return [];
        case "keyboard":
            if (isKde)
                return ["dbus-send", "--session", "--type=method_call", "--dest=org.kde.keyboard", "/Layouts", "org.kde.KeyboardLayouts.switchToNextLayout"];
            if (de === "hyprland")
                return ["hyprctl", "switchxkblayout", "all", "next"];
            if (de === "sway")
                return ["swaymsg", "input", "type:keyboard", "xkb_switch_layout", "next"];
            if (de === "niri")
                return ["niri", "msg", "action", "switch-layout", "next"];
            return [];
        case "terminal":
            return [terminal];
        case "files":
            return ["xdg-open", Quickshell.env("HOME") || "/"];
        case "lock":
            return ["loginctl", "lock-session"];
        case "sleep":
            return ["systemctl", "suspend"];
        case "hibernate":
            return ["systemctl", "hibernate"];
        case "logout":
            if (isKde)
                return ["dbus-send", "--session", "--type=method_call", "--dest=org.kde.LogoutPrompt", "/LogoutPrompt", "org.kde.LogoutPrompt.promptLogout"];
            if (de === "hyprland")
                return ["hyprctl", "dispatch", "exit"];
            if (de === "sway")
                return ["swaymsg", "exit"];
            if (de === "niri")
                return ["niri", "msg", "action", "quit", "--skip-confirmation"];
            if (isGnome)
                return ["gnome-session-quit", "--logout"];
            return ["sh", "-c", "loginctl terminate-session \"$XDG_SESSION_ID\""];
        case "restart":
            return isKde ? ["dbus-send", "--session", "--type=method_call", "--dest=org.kde.LogoutPrompt", "/LogoutPrompt", "org.kde.LogoutPrompt.promptReboot"] : ["systemctl", "reboot"];
        case "shutdown":
            return isKde ? ["dbus-send", "--session", "--type=method_call", "--dest=org.kde.LogoutPrompt", "/LogoutPrompt", "org.kde.LogoutPrompt.promptShutDown"] : ["systemctl", "poweroff"];
        case "systemsettings":
            if (has("systemsettings"))
                return ["systemsettings"];
            if (has("gnome-control-center"))
                return ["gnome-control-center"];
            if (has("nwg-look"))
                return ["nwg-look"];
            return [];
        case "netsettings":
            if (has("systemsettings"))
                return ["systemsettings", "kcm_networkmanagement"];
            if (has("gnome-control-center"))
                return ["gnome-control-center", "wifi"];
            if (has("nm-connection-editor"))
                return ["nm-connection-editor"];
            return [];
        case "btsettings":
            if (has("systemsettings"))
                return ["systemsettings", "kcm_bluetooth"];
            if (has("gnome-control-center"))
                return ["gnome-control-center", "bluetooth"];
            if (has("blueman-manager"))
                return ["blueman-manager"];
            return [];
        case "soundsettings":
            if (has("systemsettings"))
                return ["systemsettings", "kcm_pulseaudio"];
            if (has("gnome-control-center"))
                return ["gnome-control-center", "sound"];
            if (has("pwvucontrol"))
                return ["pwvucontrol"];
            if (has("pavucontrol"))
                return ["pavucontrol"];
            return [];
        case "displaysettings":
            if (has("systemsettings"))
                return ["systemsettings", "kcm_kscreen"];
            if (has("gnome-control-center"))
                return ["gnome-control-center", "display"];
            if (has("nwg-displays"))
                return ["nwg-displays"];
            if (has("wdisplays"))
                return ["wdisplays"];
            return [];
        case "nightlightsettings":
            return has("systemsettings") ? ["systemsettings", "kcm_nightlight"] : has("gnome-control-center") ? ["gnome-control-center", "display"] : [];
        case "sysmonitor":
            if (has("plasma-systemmonitor"))
                return ["plasma-systemmonitor"];
            if (has("gnome-system-monitor"))
                return ["gnome-system-monitor"];
            if (has("btop"))
                return inTerminal(["btop"]);
            if (has("htop"))
                return inTerminal(["htop"]);
            return [];
        }
        return [];
    }

    // How to add a keyboard shortcut on this desktop (for the welcome tour).
    readonly property var shortcutSteps: {
        switch (de) {
        case "kde":
            return ["Open System Settings → Keyboard → Shortcuts.", "Click \"Add New\" → \"Command or Script…\".", "Paste this command (copy button below), then pick a key:"];
        case "gnome":
            return ["Open Settings → Keyboard → View and Customise Shortcuts → Custom Shortcuts.", "Click \"+\", give it a name.", "Paste this command, then pick a key:"];
        case "hyprland":
            return ["Open ~/.config/hypr/hyprland.conf in a text editor.", "Add this line at the end (copy button below):", "Save. Hyprland reloads it by itself."];
        case "sway":
            return ["Open ~/.config/sway/config in a text editor.", "Add this line at the end (copy button below):", "Save, then press Super+Shift+C to reload Sway."];
        case "niri":
            return ["Open ~/.config/niri/config.kdl in a text editor.", "Inside the binds { } block, add this line:", "Save. niri reloads it by itself."];
        }
        return ["Open your desktop's keyboard shortcut settings.", "Add a custom shortcut that runs a command.", "Paste this command, then pick a key:"];
    }
    // The line to paste for a shortcut that runs `command`.
    function shortcutLine(command) {
        switch (de) {
        case "hyprland":
            return "bind = SUPER, C, exec, " + command;
        case "sway":
            return "bindsym $mod+c exec " + command;
        case "niri":
            return "Mod+C { spawn \"sh\" \"-c\" \"" + command + "\"; }";
        }
        return command;
    }

    // ---- Home (Windows) key opens the pill -------------------------------------
    readonly property string superKeyCommand: "qs -c archpill ipc call archpill superKey"
    // Hyprland and Sway can be set up automatically (a marked line is added to
    // their config and removed again when you turn it off / uninstall).
    readonly property bool superKeyAutomatic: de === "hyprland" || de === "sway"
    readonly property string superKeyLine: de === "hyprland" ? "bindr = SUPER, SUPER_L, exec, " + superKeyCommand : de === "sway" ? "bindsym --release Super_L exec " + superKeyCommand : ""
    readonly property string superKeyFile: de === "hyprland" ? (Quickshell.env("HOME") + "/.config/hypr/hyprland.conf") : de === "sway" ? (Quickshell.env("HOME") + "/.config/sway/config") : ""
    property bool superKeyEnabled: false

    function checkSuperKey() {
        if (superKeyFile !== "")
            superCheck.running = true;
    }
    function setSuperKey(on) {
        if (!superKeyAutomatic)
            return;
        superKeyEnabled = on;
        const reload = de === "hyprland" ? "hyprctl reload >/dev/null" : "swaymsg reload >/dev/null";
        const script = on ? "grep -q archpill-superkey \"$1\" || printf '\\n# archpill-superkey (added by ArchPill)\\n%s\\n' \"$2\" >> \"$1\"; " + reload : "sed -i '/archpill-superkey/{N;d;}' \"$1\"; " + reload;
        Quickshell.execDetached(["sh", "-c", script, "sh", superKeyFile, superKeyLine]);
    }
    Process {
        id: superCheck
        command: ["grep", "-q", "archpill-superkey", root.superKeyFile]
        onExited: code => root.superKeyEnabled = code === 0
    }
    Component.onCompleted: checkSuperKey()

    // True if this desktop can do the action.
    function can(action) {
        return cmd(action).length > 0;
    }

    function run(action) {
        const c = cmd(action);
        if (c.length > 0)
            Quickshell.execDetached(c);
        else
            console.warn("[archpill] '" + action + "' isn't available on " + niceName);
    }
}
