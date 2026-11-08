import QtQuick
import Quickshell
import qs
import qs.components
import qs.services

// Font chooser: search, filter, popular picks, and a list of every installed
// font shown in its own style. "Get more fonts" installs a big free font pack.
Column {
    id: root
    width: parent ? parent.width : 500
    spacing: 10

    property string search: ""
    property string kind: "all"
    readonly property var allFonts: Qt.fontFamilies()

    readonly property var popular: ["Inter", "Noto Sans", "Roboto", "Open Sans", "Ubuntu", "Fira Sans", "Source Sans 3", "IBM Plex Sans", "Cantarell", "Lato", "DejaVu Sans", "Liberation Sans", "JetBrains Mono", "Fira Code", "Cascadia Code", "Hack", "Iosevka", "Source Serif 4", "Noto Serif", "IBM Plex Serif"]
    readonly property var popularInstalled: popular.filter(f => allFonts.indexOf(f) !== -1)

    function kindOf(f) {
        const n = f.toLowerCase();
        if (/mono|code|consol|courier|hack|iosevka|inconsolata|cascadia|terminal|fixed/.test(n))
            return "mono";
        if (/serif/.test(n) && !/sans/.test(n))
            return "serif";
        if (/garamond|times|georgia|libertin|crimson|caladea|junicode|gelasio|baskerville|bodoni|palatino|book/.test(n))
            return "serif";
        return "sans";
    }
    readonly property var shown: allFonts.filter(f => (kind === "all" || kindOf(f) === kind) && (search === "" || f.toLowerCase().indexOf(search) !== -1))

    // Current font preview
    Rectangle {
        width: parent.width
        height: 64
        radius: 12
        color: Qt.rgba(Config.foreground.r, Config.foreground.g, Config.foreground.b, 0.06)
        Column {
            anchors.verticalCenter: parent.verticalCenter
            x: 14
            width: parent.width - 28
            Text {
                width: parent.width
                elide: Text.ElideRight
                text: "12:30  ·  Midnight City  ·  83%"
                color: Config.foreground
                font.family: Config.fontFamily !== "" ? Config.fontFamily : Qt.application.font.family
                font.pixelSize: 20
            }
            PillText {
                text: Config.fontFamily === "" ? "Plasma default (" + Qt.application.font.family + ")" : Config.fontFamily
                color: Config.subtle
                sizeFactor: 0.85
            }
        }
    }

    // Popular picks that you have installed
    Flow {
        width: parent.width
        spacing: 4
        SmallButton {
            label: "Plasma default"
            highlight: Config.fontFamily === ""
            onClicked: Config.setValue("font.family", "")
        }
        Repeater {
            model: root.popularInstalled
            delegate: SmallButton {
                required property var modelData
                label: modelData
                highlight: Config.fontFamily === modelData
                onClicked: Config.setValue("font.family", modelData)
            }
        }
    }

    // Search + filter
    Row {
        width: parent.width
        spacing: 8
        TextBox {
            width: parent.width - kinds.width - 8
            placeholder: "Search " + root.allFonts.length + " fonts…"
            onEdited: t => root.search = t.toLowerCase()
        }
        Choice {
            id: kinds
            width: 250
            options: [{ label: "All", value: "all" }, { label: "Sans", value: "sans" }, { label: "Serif", value: "serif" }, { label: "Mono", value: "mono" }]
            current: root.kind
            onPicked: v => root.kind = v
        }
    }

    // Every font, previewed in itself (only visible rows are drawn).
    Rectangle {
        width: parent.width
        height: 300
        radius: 12
        color: Qt.rgba(Config.foreground.r, Config.foreground.g, Config.foreground.b, 0.04)
        border.width: 1
        border.color: Qt.rgba(Config.foreground.r, Config.foreground.g, Config.foreground.b, 0.08)
        clip: true

        ListView {
            id: list
            anchors.fill: parent
            anchors.margins: 4
            model: root.shown
            boundsBehavior: Flickable.StopAtBounds
            delegate: Rectangle {
                required property var modelData
                readonly property bool current: Config.fontFamily === modelData
                width: list.width
                height: 40
                radius: 8
                color: current ? Qt.rgba(Config.accent.r, Config.accent.g, Config.accent.b, 0.3) : fm.containsMouse ? Qt.rgba(Config.foreground.r, Config.foreground.g, Config.foreground.b, 0.08) : "transparent"
                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    x: 10
                    width: parent.width * 0.45
                    elide: Text.ElideRight
                    text: modelData
                    color: Config.foreground
                    font.family: modelData
                    font.pixelSize: 15
                }
                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: parent.right
                    anchors.rightMargin: 10
                    width: parent.width * 0.5
                    horizontalAlignment: Text.AlignRight
                    elide: Text.ElideRight
                    text: "12:30 · Midnight City"
                    color: Config.subtle
                    font.family: modelData
                    font.pixelSize: 13
                }
                MouseArea {
                    id: fm
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Config.setValue("font.family", modelData)
                }
            }
        }
        PillText {
            visible: root.shown.length === 0
            anchors.centerIn: parent
            text: "No fonts match"
            color: Config.subtle
        }
    }

    // More fonts
    Row {
        spacing: 8
        SmallButton {
            label: "Get more fonts"
            highlight: true
            onClicked: Quickshell.execDetached([Config.terminal, "-e", "sh", "-c", "cd \"$1\" && ./install.sh --fonts; echo; echo 'Done. Press Enter to close, then restart ArchPill to see the new fonts.'; read x", "sh", Updater.repo])
        }
        SmallButton {
            label: "Restart ArchPill"
            onClicked: Updater.restart()
        }
    }
    PillText {
        width: parent.width
        wrapMode: Text.Wrap
        maximumLineCount: 3
        text: "\"Get more fonts\" opens a terminal and installs a pack of free fonts (Inter, JetBrains Mono, Fira, Roboto, IBM Plex, Ubuntu, Hack, Cascadia and more). It asks for your password. Then press Restart ArchPill."
        color: Config.subtle
        sizeFactor: 0.85
    }
}
