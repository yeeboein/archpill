import QtQuick
import Quickshell
import Quickshell.Wayland
import qs
import qs.services
import qs.modules as M

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

    anchors.top: true
    exclusionMode: ExclusionMode.Ignore
    exclusiveZone: 0
    color: "transparent"

    WlrLayershell.namespace: "archpill"
    WlrLayershell.layer: Config.layer === "top" ? WlrLayer.Top : WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    // Big enough for the widest/tallest pill; the transparent part costs
    // almost nothing and is click-through thanks to the mask.
    implicitWidth: Math.max(Config.pillMaxWidth, Config.triggerWidth, Config.mediaWidth, Config.controlWidth) + 16
    implicitHeight: Config.topMargin + Math.max(Config.pillHeight, Config.expandedMaxHeight) + 8

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
    readonly property int expandedPad: 16

    // ---- reveal logic -------------------------------------------------------
    readonly property bool hovering: pillHover.hovered || triggerHover.hovered
    property bool revealed: false
    readonly property bool open: revealed || PillState.pinned || expanded || PillState.settingsOpen || Config.alwaysOpen

    onHoveringChanged: {
        if (hovering) {
            hideTimer.stop();
            closeTimer.stop();
            if (!revealed)
                showTimer.restart();
        } else {
            showTimer.stop();
            hideTimer.restart();
            if (expanded && Config.closeOnLeave)
                closeTimer.restart();
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
        interval: Config.closeDelay
        onTriggered: if (win.expanded && !win.hovering) PillState.close()
    }

    mask: Region {
        item: trigger
        Region {
            item: win.open ? hitbox : null
        }
    }

    // ---- modules ------------------------------------------------------------
    // Name in config ("pill.modules") -> module. Add new modules here
    // and in Modules.qml.
    function componentFor(name) {
        switch (String(name).toLowerCase()) {
        case "clock":
            return clockModule;
        case "media":
            return mediaModule;
        case "volume":
            return volumeModule;
        case "battery":
            return batteryModule;
        case "control":
            return controlModule;
        case "network":
            return networkModule;
        case "bluetooth":
            return bluetoothModule;
        case "mic":
            return micModule;
        case "weather":
            return weatherModule;
        case "separator":
            return separatorModule;
        }
        Modules.warnUnknown(name);
        return null;
    }

    Component {
        id: clockModule
        M.Clock {}
    }
    Component {
        id: mediaModule
        M.Media {
            screenName: win.screenName
        }
    }
    Component {
        id: volumeModule
        M.Volume {}
    }
    Component {
        id: batteryModule
        M.Battery {}
    }
    Component {
        id: controlModule
        M.Control {
            screenName: win.screenName
        }
    }

    Component {
        id: networkModule
        M.Wifi {}
    }
    Component {
        id: bluetoothModule
        M.BluetoothStatus {}
    }
    Component {
        id: micModule
        M.Mic {}
    }
    Component {
        id: weatherModule
        M.WeatherTemp {}
    }
    Component {
        id: separatorModule
        M.Separator {}
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
    Rectangle {
        anchors.horizontalCenter: parent.horizontalCenter
        y: 2
        width: 64
        height: 4
        radius: 2
        color: Config.foreground
        opacity: (Config.idleMode === "tiny" && !win.open) ? 0.35 : 0
        visible: opacity > 0
        Behavior on opacity {
            NumberAnimation {
                duration: Config.animDuration
            }
        }
    }

    // Thin strip at the top edge that wakes the pill up.
    Item {
        id: trigger
        anchors.horizontalCenter: parent.horizontalCenter
        y: 0
        width: Config.triggerWidth
        height: Config.idleMode === "tiny" ? Math.max(Config.triggerHeight, 6) : Config.triggerHeight
        HoverHandler {
            id: triggerHover
        }
    }

    // ---- the pill -----------------------------------------------------------
    // `hitbox` spans from the top edge down to the bottom of the open pill, so
    // the mouse never "falls through" the gap above the pill.
    Item {
        id: hitbox
        anchors.horizontalCenter: parent.horizontalCenter
        y: 0
        width: pill.width
        height: Config.topMargin + pill.height

        HoverHandler {
            id: pillHover
        }

        Rectangle {
            id: pill

            readonly property int compactWidth: Math.max(Config.pillMinWidth, Math.min(Config.pillMaxWidth, modulesRow.implicitWidth + Config.pillPadding * 2))
            readonly property int bigWidth: win.mode === "media" ? Config.mediaWidth : Config.controlWidth
            readonly property int bigHeight: Math.min(Config.expandedMaxHeight, (bigView.item ? bigView.item.implicitHeight : 0) + win.expandedPad * 2)

            anchors.horizontalCenter: parent.horizontalCenter
            width: win.expanded ? bigWidth : compactWidth
            height: win.expanded ? Math.max(Config.pillHeight, bigHeight) : Config.pillHeight
            radius: win.expanded ? Config.expandedRadius : Math.min(Config.pillRadius, height / 2)
            color: Config.pillColor
            border.width: 1
            border.color: Qt.rgba(1, 1, 1, 0.06)
            clip: true

            y: win.open ? Config.topMargin : -height - 2
            // Don't draw anything while fully hidden.
            visible: y > -height

            Behavior on y {
                NumberAnimation {
                    duration: Config.animDuration
                    easing.type: Easing.OutCubic
                }
            }
            Behavior on width {
                enabled: win.open
                NumberAnimation {
                    duration: Config.animDuration
                    easing.type: Easing.OutCubic
                }
            }
            Behavior on height {
                NumberAnimation {
                    duration: Config.animDuration
                    easing.type: Easing.OutCubic
                }
            }
            Behavior on radius {
                NumberAnimation {
                    duration: Config.animDuration
                }
            }

            // Click on an empty part of the pill (configurable).
            MouseArea {
                anchors.fill: parent
                enabled: !win.expanded && Config.clickAction !== "none"
                cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                onClicked: PillState.toggle(Config.clickAction === "media" ? "media" : "control", win.screenName)
            }

            // Normal (compact) contents.
            Row {
                id: modulesRow
                anchors.centerIn: parent
                spacing: Config.pillSpacing
                opacity: win.expanded ? 0 : 1
                visible: opacity > 0
                Behavior on opacity {
                    NumberAnimation {
                        duration: Config.animDuration / 2
                    }
                }

                Repeater {
                    model: Config.modules

                    delegate: Loader {
                        required property var modelData
                        anchors.verticalCenter: parent ? parent.verticalCenter : undefined
                        sourceComponent: win.componentFor(modelData)
                        visible: status === Loader.Ready && !!item && item.shown !== false
                    }
                }
            }

            // Expanded contents (only created while open, to save memory).
            // Scrolls if it is taller than "expanded.maxHeight".
            Flickable {
                x: win.expandedPad
                y: win.expandedPad
                width: pill.bigWidth - win.expandedPad * 2
                height: pill.height - win.expandedPad * 2
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
                        NumberAnimation {
                            duration: Config.animDuration / 2
                        }
                    }
                }
            }
        }
    }
}
