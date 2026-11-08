import QtQuick
import Quickshell
import qs
import qs.components
import qs.services

// First-run tour. Opens automatically the first time ArchPill starts
// (until "setup.done" is true in the config). Reopen it any time from
// Settings → Shortcuts & Reset, or `qs -c archpill ipc call archpill welcome`.
FloatingWindow {
    id: win

    title: "Welcome to ArchPill"
    implicitWidth: 640
    implicitHeight: 540
    minimumSize: Qt.size(560, 480)
    color: Qt.rgba(Config.background.r, Config.background.g, Config.background.b, 1)

    property int step: 0
    readonly property var steps: ["welcome", "use", "volume", "look", "behaviour", "shortcut", "done"]
    readonly property string shortcutCmd: "qs -c archpill ipc call archpill toggleControlCenter"
    property bool copied: false

    function finish() {
        Config.setValue("setup.done", true);
        PillState.pinned = false;
        PillState.welcomeOpen = false;
    }

    // Closing the window counts as done, so it doesn't nag you.
    onClosed: finish()
    Component.onCompleted: Plasma.refresh()

    // ---- step content ----------------------------------------------------------
    Item {
        id: content
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: footer.top
        anchors.margins: 32

        Loader {
            anchors.fill: parent
            sourceComponent: {
                switch (win.steps[win.step]) {
                case "use":
                    return useStep;
                case "volume":
                    return volumeStep;
                case "look":
                    return lookStep;
                case "behaviour":
                    return behaviourStep;
                case "shortcut":
                    return shortcutStep;
                case "done":
                    return doneStep;
                }
                return welcomeStep;
            }
        }
    }

    // ---- footer: dots + back/next ---------------------------------------------
    Item {
        id: footer
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: 68

        Rectangle {
            width: parent.width
            height: 1
            color: Qt.rgba(Config.foreground.r, Config.foreground.g, Config.foreground.b, 0.08)
        }
        SmallButton {
            anchors.left: parent.left
            anchors.leftMargin: 24
            anchors.verticalCenter: parent.verticalCenter
            label: win.step === 0 ? "Skip tour" : "Back"
            onClicked: win.step === 0 ? win.finish() : win.step--
        }
        Row {
            anchors.centerIn: parent
            spacing: 6
            Repeater {
                model: win.steps.length
                delegate: Rectangle {
                    required property int index
                    width: index === win.step ? 18 : 7
                    height: 7
                    radius: 4
                    color: index === win.step ? Config.accent : Qt.rgba(Config.foreground.r, Config.foreground.g, Config.foreground.b, 0.25)
                    Behavior on width {
                        NumberAnimation {
                            duration: 120
                        }
                    }
                }
            }
        }
        SmallButton {
            anchors.right: parent.right
            anchors.rightMargin: 24
            anchors.verticalCenter: parent.verticalCenter
            highlight: true
            label: win.step === win.steps.length - 1 ? "Finish" : "Next"
            onClicked: win.step === win.steps.length - 1 ? win.finish() : win.step++
        }
    }

    // ---- reusable bits ---------------------------------------------------------
    component Title: PillText {
        width: parent ? parent.width : 400
        font.weight: Font.Bold
        sizeFactor: 1.8
        wrapMode: Text.Wrap
        maximumLineCount: 2
    }
    component Body: PillText {
        width: parent ? parent.width : 400
        color: Config.subtle
        sizeFactor: 1.1
        wrapMode: Text.Wrap
        maximumLineCount: 8
        lineHeight: 1.2
    }
    component Step: Row {
        property string number
        property string text
        width: parent ? parent.width : 400
        spacing: 12
        Rectangle {
            width: 26
            height: 26
            radius: 13
            color: Config.accent
            PillText {
                anchors.centerIn: parent
                text: parent.parent.number
                color: "#ffffff"
                font.weight: Font.Bold
            }
        }
        PillText {
            width: parent.width - 40
            anchors.verticalCenter: parent.verticalCenter
            text: parent.text
            sizeFactor: 1.05
            wrapMode: Text.Wrap
            maximumLineCount: 3
        }
    }

    // ---- steps -----------------------------------------------------------------
    Component {
        id: welcomeStep
        Column {
            spacing: 18
            Item {
                anchors.horizontalCenter: parent.horizontalCenter
                width: 140
                height: 140
                Image {
                    anchors.fill: parent
                    anchors.margins: 0
                    source: Qt.resolvedUrl("../assets/logo.png")
                    sourceSize: Qt.size(280, 280)
                    fillMode: Image.PreserveAspectFit
                    mipmap: true
                }
            }
            Title {
                horizontalAlignment: Text.AlignHCenter
                text: "Welcome to ArchPill!"
            }
            Body {
                horizontalAlignment: Text.AlignHCenter
                text: "ArchPill is a little pill at the top of your screen, like the Dynamic Island on an iPhone. It shows the time, your music, volume and battery, and opens a control centre.\n\nThis short tour sets it up. It takes about a minute."
            }
        }
    }

    Component {
        id: useStep
        Column {
            spacing: 16
            Title {
                text: "How to use it"
            }
            Step {
                number: "1"
                text: "Move your mouse to the top-middle edge of the screen. The pill slides down."
            }
            Step {
                number: "2"
                text: "Click the song name to open the big music player."
            }
            Step {
                number: "3"
                text: "Click the sliders icon (or an empty part of the pill) to open the control centre."
            }
            Step {
                number: "4"
                text: "Move your mouse away and it hides again."
            }
            Row {
                spacing: 8
                topPadding: 8
                SmallButton {
                    label: PillState.pinned ? "Hide the pill" : "Show me the pill"
                    highlight: !PillState.pinned
                    onClicked: PillState.pinned = !PillState.pinned
                }
                SmallButton {
                    label: "Open the control centre"
                    onClicked: PillState.open("control", "")
                }
            }
        }
    }

    Component {
        id: volumeStep
        Column {
            spacing: 14
            Title {
                text: "Volume in the pill"
            }
            Body {
                text: Desktop.isKde ? "When you change the volume, the pill shows a volume bar for a moment. Plasma also shows its own popup in the middle of the screen, so you'd see two. Turn Plasma's off to only see the pill. (You can turn it back on any time, and uninstalling ArchPill does it for you.)" : "When you change the volume, the pill shows a volume bar for a moment."
            }
            Rectangle {
                width: parent.width
                height: volCol.implicitHeight + 24
                radius: 14
                color: Qt.rgba(Config.foreground.r, Config.foreground.g, Config.foreground.b, 0.05)
                Column {
                    id: volCol
                    x: 14
                    y: 12
                    width: parent.width - 28
                    spacing: 2
                    SettingRow {
                        label: "Show volume changes in the pill"
                        Toggle {
                            checked: Config.osdEnabled
                            onToggled: v => Config.setValue("osd.enabled", v)
                        }
                    }
                    SettingRow {
                        visible: Desktop.isKde
                        label: "Plasma's own volume popup"
                        description: Plasma.plasmaVolumePopup ? "Currently ON - you'll see two popups" : "Currently OFF - only the pill shows volume ✓"
                        controlWidth: 200
                        SmallButton {
                            anchors.right: parent.right
                            label: Plasma.plasmaVolumePopup ? "Turn Plasma's off" : "Turn it back on"
                            highlight: Plasma.plasmaVolumePopup
                            onClicked: Plasma.setPlasmaVolumePopup(!Plasma.plasmaVolumePopup)
                        }
                    }
                    SettingRow {
                        label: "Try it"
                        description: "Or press your volume keys"
                        controlWidth: 160
                        SmallButton {
                            anchors.right: parent.right
                            label: "Show the popup"
                            onClicked: PillState.showOsd("volume")
                        }
                    }
                }
            }
            Body {
                visible: Desktop.isKde && Plasma.plasmaVolumePopup === false
                text: "If Plasma's popup still appears after this, log out and back in once."
                sizeFactor: 0.95
            }
        }
    }

    Component {
        id: lookStep
        Column {
            spacing: 14
            Title {
                text: "Pick a look"
            }
            Body {
                text: "Choose colours for the pill. You can fine-tune everything later in Settings."
            }
            Flow {
                width: parent.width
                spacing: 8
                Repeater {
                    model: Themes.all
                    delegate: Rectangle {
                        required property var modelData
                        width: 132
                        height: 58
                        radius: 14
                        color: modelData.c.background
                        border.width: Themes.isCurrent(modelData) ? 3 : 1
                        border.color: Themes.isCurrent(modelData) ? Config.accent : Qt.rgba(0.5, 0.5, 0.5, 0.4)
                        Column {
                            anchors.centerIn: parent
                            spacing: 4
                            Row {
                                anchors.horizontalCenter: parent.horizontalCenter
                                spacing: 4
                                Repeater {
                                    model: [modelData.c.foreground, modelData.c.subtle, modelData.c.accent]
                                    delegate: Rectangle {
                                        required property var modelData
                                        width: 12
                                        height: 12
                                        radius: 6
                                        color: modelData
                                    }
                                }
                            }
                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: modelData.name
                                color: modelData.c.foreground
                                font.pixelSize: 12
                            }
                        }
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                Themes.apply(modelData);
                                PillState.pinned = true; // show the pill so you can see it
                            }
                        }
                    }
                }
            }
        }
    }

    Component {
        id: behaviourStep
        Column {
            spacing: 14
            Title {
                text: "Hide or always show?"
            }
            Body {
                text: "By default the pill hides and slides down when your mouse touches the top edge. You can keep it on screen all the time instead."
            }
            Rectangle {
                width: parent.width
                height: behCol.implicitHeight + 24
                radius: 14
                color: Qt.rgba(Config.foreground.r, Config.foreground.g, Config.foreground.b, 0.05)
                Column {
                    id: behCol
                    x: 14
                    y: 12
                    width: parent.width - 28
                    spacing: 2
                    SettingRow {
                        label: "Pill"
                        controlWidth: 300
                        Choice {
                            options: [{ label: "Hide until I hover", value: false }, { label: "Always show", value: true }]
                            current: Config.alwaysOpen
                            onPicked: v => Config.setValue("pill.alwaysOpen", v)
                        }
                    }
                    SettingRow {
                        visible: !Config.alwaysOpen
                        label: "While hidden, show"
                        controlWidth: 300
                        Choice {
                            options: [{ label: "A tiny bar", value: "tiny" }, { label: "Nothing", value: "hidden" }]
                            current: Config.idleMode
                            onPicked: v => Config.setValue("pill.idleMode", v)
                        }
                    }
                    SettingRow {
                        label: "Animations"
                        description: "Off is lightest on slow computers"
                        controlWidth: 300
                        Choice {
                            options: [{ label: "Off", value: 0 }, { label: "Fast", value: 120 }, { label: "Normal", value: 180 }]
                            current: Config.animDuration
                            onPicked: v => Config.setValue("animation.duration", v)
                        }
                    }
                }
            }
        }
    }

    Component {
        id: shortcutStep
        Column {
            spacing: 14
            Title {
                text: "Optional: a keyboard shortcut"
            }
            Body {
                text: "You can open the control centre with a key, e.g. Super+C."
            }
            // Steps for your desktop
            Repeater {
                model: Desktop.shortcutSteps
                delegate: Step {
                    required property var modelData
                    required property int index
                    number: String(index + 1)
                    text: modelData
                }
            }
            Rectangle {
                width: parent.width
                height: 44
                radius: 10
                color: Qt.rgba(Config.foreground.r, Config.foreground.g, Config.foreground.b, 0.08)
                PillText {
                    anchors.verticalCenter: parent.verticalCenter
                    x: 12
                    width: parent.width - 110
                    text: Desktop.shortcutLine(win.shortcutCmd)
                    font.family: "monospace"
                    sizeFactor: 0.95
                }
                SmallButton {
                    anchors.right: parent.right
                    anchors.rightMargin: 7
                    anchors.verticalCenter: parent.verticalCenter
                    label: win.copied ? "Copied ✓" : "Copy"
                    highlight: !win.copied
                    onClicked: {
                        Quickshell.clipboardText = Desktop.shortcutLine(win.shortcutCmd);
                        win.copied = true;
                    }
                }
            }
            Row {
                spacing: 8
                SmallButton {
                    visible: Desktop.isKde || Desktop.isGnome
                    label: "Open shortcut settings"
                    onClicked: Quickshell.execDetached(Desktop.isKde ? ["systemsettings", "kcm_keys"] : ["gnome-control-center", "keyboard"])
                }
            }
        }
    }

    Component {
        id: doneStep
        Column {
            spacing: 18
            Title {
                horizontalAlignment: Text.AlignHCenter
                text: "You're all set! 🎉"
            }
            Body {
                horizontalAlignment: Text.AlignHCenter
                text: "ArchPill starts by itself every time you log in.\n\nWant to change what's in the pill, add control-centre widgets, apps or your own buttons? Open ArchPill Settings: it's in your app menu, and behind the palette button in the control centre."
            }
            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 8
                SmallButton {
                    label: "Open Settings now"
                    highlight: true
                    onClicked: {
                        win.finish();
                        PillState.settingsOpen = true;
                    }
                }
            }
        }
    }
}
