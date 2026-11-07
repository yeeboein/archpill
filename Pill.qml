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
PanelWindow {
    id: win

    required property var modelData
    screen: modelData

    anchors.top: true
    exclusionMode: ExclusionMode.Ignore
    exclusiveZone: 0
    color: "transparent"

    WlrLayershell.namespace: "archpill"
    WlrLayershell.layer: Config.layer === "top" ? WlrLayer.Top : WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    // Big enough for the widest pill; the transparent part costs ~nothing
    // and is click-through thanks to the mask.
    implicitWidth: Math.max(Config.pillMaxWidth, Config.triggerWidth) + 16
    implicitHeight: Config.topMargin + Config.pillHeight + 8

    // ---- reveal logic -------------------------------------------------------
    readonly property bool hovering: pillHover.hovered || triggerHover.hovered
    property bool revealed: false
    readonly property bool open: revealed || PillState.pinned

    onHoveringChanged: {
        if (hovering) {
            hideTimer.stop();
            if (!revealed)
                showTimer.restart();
        } else {
            showTimer.stop();
            hideTimer.restart();
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
        M.Media {}
    }
    Component {
        id: volumeModule
        M.Volume {}
    }
    Component {
        id: batteryModule
        M.Battery {}
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

            readonly property int contentWidth: modulesRow.implicitWidth + Config.pillPadding * 2

            anchors.horizontalCenter: parent.horizontalCenter
            width: Math.max(Config.pillMinWidth, Math.min(Config.pillMaxWidth, contentWidth))
            height: Config.pillHeight
            radius: Math.min(Config.pillRadius, height / 2)
            color: Config.pillColor
            border.width: 1
            border.color: Qt.rgba(1, 1, 1, 0.06)
            clip: true

            y: win.open ? Config.topMargin : -height - 2
            // Don't draw anything while fully hidden.
            visible: y > -height

            Behavior on y {
                NumberAnimation {
                    id: slide
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

            Row {
                id: modulesRow
                anchors.centerIn: parent
                spacing: Config.pillSpacing

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
        }
    }
}
