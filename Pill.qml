import QtQuick
import Quickshell
import Quickshell.Wayland
import qs
import qs.services
import qs.components

// The pill: one transparent layer-shell window at the top-centre of a screen.
//
// How hover-reveal works without covering anything:
//  - The window never reserves screen space (ExclusionMode.Ignore).
//  - Its input `mask` decides where it catches the mouse. While hidden, that
//    is only a thin strip at the very top edge (`trigger`). Everything else
//    clicks straight through to your windows.
//  - Touching the strip slides the pill down; the mask then grows to cover the
//    pill. When the mouse leaves, the pill slides back up after a short delay.
//
// The pill can also grow ("expand") into the music dropdown or the control
// centre. It closes again when the mouse leaves it (see "expanded" config).
PanelWindow {
    id: win

    required property var modelData
    screen: modelData
    readonly property string screenName: modelData ? modelData.name : ""

    // ---- where on the screen (Settings → Behaviour → Position) ---------------
    // "top", "top-left", "top-right", "bottom", "bottom-left", "bottom-right",
    // "left" or "right" (middle of that side).
    readonly property string pos: Config.position
    readonly property bool atTop: pos.indexOf("top") === 0
    readonly property bool atBottom: pos.indexOf("bottom") === 0
    readonly property bool onSide: pos === "left" || pos === "right"   // slides in sideways
    readonly property string hAlign: pos.indexOf("left") !== -1 ? "left" : pos.indexOf("right") !== -1 ? "right" : "center"
    readonly property int gap: Config.topMargin       // distance from the edge it's attached to
    readonly property int sideGap: Config.edgeMargin  // distance from the side, in the corners

    anchors.top: atTop
    anchors.bottom: atBottom
    anchors.left: hAlign === "left"
    anchors.right: hAlign === "right"
    exclusionMode: ExclusionMode.Ignore
    exclusiveZone: 0
    color: "transparent"

    WlrLayershell.namespace: "archpill"
    WlrLayershell.layer: Config.layer === "top" ? WlrLayer.Top : WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    // Big enough for the widest/tallest pill; the transparent part costs
    // almost nothing and is click-through thanks to the mask.
    implicitWidth: Math.max(Config.pillMaxWidth, Config.triggerWidth, Math.max(Config.mediaWidth, Config.controlWidth) + Config.hoverMargin * 2) + 16 + Math.max(Config.edgeMargin, Config.topMargin)
    implicitHeight: Math.max(Config.topMargin + Math.max(Config.pillHeight, Config.expandedMaxHeight) + osdStripHeight + Config.hoverMargin + 8, onSide ? Config.triggerWidth : 0)

    // Where the open pill sits inside this window, and where it hides.
    readonly property real restX: hAlign === "left" ? (onSide ? gap : sideGap) : hAlign === "right" ? width - pill.width - (onSide ? gap : sideGap) : (width - pill.width) / 2
    readonly property real restY: atTop ? gap : atBottom ? height - pill.height - gap : (height - pill.height) / 2
    readonly property real hiddenX: !onSide ? restX : hAlign === "left" ? -pill.width - 4 : width + 4
    readonly property real hiddenY: onSide ? restY : atTop ? -pill.height - 4 : height + 4

    // ---- expanded mode -------------------------------------------------------
    // Which screen an IPC command (no screen given) opens on.
    readonly property bool isDefaultScreen: {
        if (Config.monitor !== "" && Config.monitor === screenName)
            return true;
        return Quickshell.screens.length > 0 && Quickshell.screens[0].name === screenName;
    }
    readonly property string mode: {
        if (PillState.expanded === "")
            return "";
        const here = PillState.screenName === "" ? isDefaultScreen : PillState.screenName === screenName;
        return here ? PillState.expanded : "";
    }
    readonly property bool expanded: mode !== ""
    // A notification is showing (the pill grows to show it).
    readonly property bool notif: !!Notifs.current && isDefaultScreen && !expanded
    // Volume popup (shown on the default screen, not while expanded or showing a notification).
    readonly property bool osd: PillState.osd !== "" && isDefaultScreen && !expanded && !notif
    // While the music player is open, volume changes appear in a small strip
    // that grows out of its bottom edge instead.
    readonly property bool osdStrip: PillState.osd !== "" && mode === "media"
    readonly property int osdStripHeight: 44
    readonly property int expandedPad: 16

    // ---- reveal logic -------------------------------------------------------
    readonly property bool hovering: pillHover.hovered || triggerHover.hovered
    property bool revealed: false
    readonly property bool open: revealed || PillState.pinned || expanded || osd || notif || PillState.settingsOpen || Config.alwaysOpen

    // Keep a notification on screen while the mouse is on it.
    Binding {
        target: Notifs
        property: "paused"
        value: win.notif && win.hovering
    }

    // Becomes true once the mouse has been on the expanded pill. Until then
    // it doesn't close quickly (the pill changes size when it opens, so the
    // mouse often ends up just outside it).
    property bool armed: false
    onExpandedChanged: {
        armed = expanded && hovering;
        closeTimer.stop();
    }

    onHoveringChanged: {
        if (hovering) {
            hideTimer.stop();
            closeTimer.stop();
            if (expanded)
                armed = true;
            if (!revealed)
                showTimer.restart();
        } else {
            showTimer.stop();
            hideTimer.restart();
            if (expanded && Config.closeOnLeave) {
                closeTimer.interval = armed ? Config.closeDelay : Math.max(Config.closeDelay, 2500);
                closeTimer.restart();
            }
        }
    }

    Timer {
        id: showTimer
        interval: Config.showDelay
        onTriggered: win.revealed = true
    }
    Timer {
        id: hideTimer
        interval: Config.hideDelay
        onTriggered: win.revealed = false
    }
    Timer {
        id: closeTimer
        onTriggered: if (win.expanded && !win.hovering) PillState.close()
    }

    mask: Region {
        item: trigger
        Region {
            item: win.open ? hitbox : null
        }
    }

    // Big views the pill can grow into.
    Component {
        id: mediaView
        MediaDropdown {}
    }
    Component {
        id: controlView
        ControlCenter {}
    }

    // ---- idle indicator ("tiny" mode) --------------------------------------
    // A small bar on the edge where the pill hides.
    Rectangle {
        width: win.onSide ? 4 : 64
        height: win.onSide ? 64 : 4
        radius: 2
        x: win.onSide ? (win.hAlign === "left" ? 2 : win.width - width - 2) : Math.max(2, Math.min(win.width - width - 2, win.restX + pill.width / 2 - width / 2))
        y: win.onSide ? (win.height - height) / 2 : win.atTop ? 2 : win.height - height - 2
        color: Config.foreground
        opacity: (Config.idleMode === "tiny" && !win.open) ? 0.35 : 0
        visible: opacity > 0
        // "Idle pulse": gently breathes while hidden (off by default: it keeps
        // the GPU awake a little).
        SequentialAnimation on scale {
            running: Config.anim("idlePulse") && Config.idleMode === "tiny" && !win.open
            loops: Animation.Infinite
            alwaysRunToEnd: true
            NumberAnimation {
                to: 1.25
                duration: 1200
                easing.type: Easing.InOutSine
            }
            NumberAnimation {
                to: 1
                duration: 1200
                easing.type: Easing.InOutSine
            }
        }
        Behavior on opacity {
            NumberAnimation {
                duration: Config.animDuration
            }
        }
    }

    // Thin strip along the edge that wakes the pill up.
    Item {
        id: trigger
        readonly property int thickness: Config.idleMode === "tiny" ? Math.max(Config.triggerHeight, 6) : Config.triggerHeight
        readonly property int length: Math.min(Config.triggerWidth, win.onSide ? win.height : win.width)
        width: win.onSide ? thickness : length
        height: win.onSide ? length : thickness
        x: win.onSide ? (win.hAlign === "left" ? 0 : win.width - width) : Math.max(0, Math.min(win.width - width, win.restX + pill.width / 2 - width / 2))
        y: win.onSide ? (win.height - height) / 2 : win.atTop ? 0 : win.height - height
        HoverHandler {
            id: triggerHover
        }
    }

    // ---- the pill -----------------------------------------------------------
    // `hitbox` spans from the screen edge to the far side of the open pill, so
    // the mouse never "falls through" the gap between the edge and the pill.
    Item {
        id: hitbox

        // Invisible margin around an expanded pill that still counts as
        // "on it", so it doesn't close the moment the mouse slips off the edge.
        readonly property int margin: win.expanded ? Config.hoverMargin : 0

        x: win.onSide ? (win.hAlign === "left" ? 0 : win.restX - margin) : Math.max(0, win.restX - margin)
        y: win.onSide ? win.restY - margin : win.atTop ? 0 : win.restY - margin
        width: win.onSide ? win.gap + pill.width + margin : Math.min(win.width - x, pill.width + margin * 2 + (win.hAlign !== "center" ? win.sideGap : 0))
        height: win.onSide ? pill.height + margin * 2 : win.gap + pill.height + margin

        HoverHandler {
            id: pillHover
        }

        Rectangle {
            id: pill

            readonly property int compactWidth: Math.max(Config.pillMinWidth, Math.min(Config.pillMaxWidth, modulesRow.implicitWidth + Config.pillPadding * 2))
            readonly property int bigWidth: win.mode === "media" ? Config.mediaWidth : Config.controlWidth
            readonly property int bigHeight: Math.min(Config.expandedMaxHeight, (bigView.item ? bigView.item.implicitHeight : 0) + win.expandedPad * 2)

            width: win.expanded ? bigWidth : win.notif ? Config.notifWidth : win.osd ? Config.osdWidth : compactWidth
            height: win.expanded ? Math.max(Config.pillHeight, bigHeight) + (win.osdStrip ? win.osdStripHeight : 0) : win.notif ? Math.max(Config.pillHeight, notifView.implicitHeight + win.expandedPad * 2) : Config.pillHeight
            radius: win.expanded ? Config.expandedRadius : win.notif ? Math.min(Config.expandedRadius, height / 2) : Math.min(Config.pillRadius, height / 2)
            color: "transparent"
            clip: true

            // Solid or liquid-glass background (Settings → Appearance → Style).
            GlassBackground {
                anchors.fill: parent
                radius: pill.radius
            }

            // Position relative to the hitbox: resting spot when open, just past
            // the screen edge when hidden.
            x: (win.open ? win.restX : win.hiddenX) - hitbox.x
            y: (win.open ? win.restY : win.hiddenY) - hitbox.y
            // Don't draw anything while fully hidden.
            visible: win.open || Math.abs(x - (win.hiddenX - hitbox.x)) > 1 || Math.abs(y - (win.hiddenY - hitbox.y)) > 1

            Behavior on x {
                enabled: win.onSide && Config.anim("slide")
                NumberAnimation {
                    duration: Config.animDuration
                    easing.type: win.open && Config.anim("bounce") ? Easing.OutBack : Easing.OutCubic
                }
            }
            Behavior on y {
                enabled: !win.onSide && Config.anim("slide")
                NumberAnimation {
                    duration: Config.animDuration
                    easing.type: win.open && Config.anim("bounce") ? Easing.OutBack : Easing.OutCubic
                }
            }

            // "Hover" animation: grows a little under the mouse.
            scale: Config.anim("hover") && win.hovering && !win.expanded && win.open ? 1.04 : 1
            transformOrigin: win.atTop ? Item.Top : win.atBottom ? Item.Bottom : win.hAlign === "left" ? Item.Left : Item.Right
            Behavior on scale {
                NumberAnimation {
                    duration: 140
                    easing.type: Easing.OutCubic
                }
            }
            Behavior on width {
                enabled: win.open && Config.anim("morph")
                NumberAnimation {
                    duration: Config.animDuration
                    easing.type: Easing.OutCubic
                }
            }
            Behavior on height {
                enabled: Config.anim("morph")
                NumberAnimation {
                    duration: Config.animDuration
                    easing.type: Easing.OutCubic
                }
            }
            Behavior on radius {
                enabled: Config.anim("morph")
                NumberAnimation {
                    duration: Config.animDuration
                }
            }

            // Click on an empty part of the pill (configurable).
            MouseArea {
                anchors.fill: parent
                enabled: !win.expanded && !win.notif && Config.clickAction !== "none"
                cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                onClicked: PillState.toggle(Config.clickAction === "media" ? "media" : "control", win.screenName)
            }

            // Normal (compact) contents.
            PillContent {
                id: modulesRow
                anchors.centerIn: parent
                screenName: win.screenName
                opacity: win.expanded || win.osd || win.notif ? 0 : 1
                visible: opacity > 0
                Behavior on opacity {
                    enabled: Config.anim("fade")
                    NumberAnimation {
                        duration: Config.animDuration / 2
                    }
                }
            }

            // Notification card.
            NotificationView {
                id: notifView
                x: win.expandedPad
                y: win.expandedPad
                width: Config.notifWidth - win.expandedPad * 2
                opacity: win.notif ? 1 : 0
                visible: opacity > 0
                enabled: win.notif
                Behavior on opacity {
                    enabled: Config.anim("fade")
                    NumberAnimation {
                        duration: Config.animDuration / 2
                    }
                }
            }

            // Volume popup: icon, bar, percentage.
            VolumeBar {
                anchors.centerIn: parent
                width: pill.width - Config.pillPadding * 2
                // "OSD pop": springs in from slightly smaller.
                scale: win.osd || !Config.anim("osdPop") ? 1 : 0.85
                Behavior on scale {
                    enabled: Config.anim("osdPop")
                    NumberAnimation {
                        duration: Config.animDuration
                        easing.type: Easing.OutBack
                    }
                }
                opacity: win.osd ? 1 : 0
                visible: opacity > 0
                Behavior on opacity {
                    enabled: Config.anim("fade")
                    NumberAnimation {
                        duration: Config.animDuration / 2
                    }
                }
            }

            // Expanded contents (only created while open, to save memory).
            // Scrolls if it is taller than "expanded.maxHeight".
            Flickable {
                x: win.expandedPad
                y: win.expandedPad
                width: pill.bigWidth - win.expandedPad * 2
                height: pill.height - win.expandedPad * 2 - (win.osdStrip ? win.osdStripHeight : 0)
                contentHeight: bigView.item ? bigView.item.implicitHeight : 0
                interactive: contentHeight > height
                boundsBehavior: Flickable.StopAtBounds
                clip: interactive
                visible: bigView.active

                Loader {
                    id: bigView
                    width: pill.bigWidth - win.expandedPad * 2
                    active: win.expanded
                    sourceComponent: win.mode === "media" ? mediaView : controlView
                    opacity: win.expanded && pill.height > Config.pillHeight + 20 ? 1 : 0
                    Behavior on opacity {
                        enabled: Config.anim("fade")
                        NumberAnimation {
                            duration: Config.animDuration / 2
                        }
                    }
                }
            }

            // Volume strip under the open music player.
            Item {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                height: win.osdStripHeight
                opacity: win.osdStrip ? 1 : 0
                visible: opacity > 0
                Behavior on opacity {
                    enabled: Config.anim("fade")
                    NumberAnimation {
                        duration: Config.animDuration / 2
                    }
                }
                Rectangle {
                    x: win.expandedPad
                    width: parent.width - win.expandedPad * 2
                    height: 1
                    color: Qt.rgba(Config.foreground.r, Config.foreground.g, Config.foreground.b, 0.1)
                }
                VolumeBar {
                    x: win.expandedPad
                    width: parent.width - win.expandedPad * 2
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.verticalCenterOffset: -2
                }
            }
        }
    }
}
