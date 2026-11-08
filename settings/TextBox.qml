import QtQuick
import qs
import qs.components

// A single-line text field. `accepted` fires on Enter or when you click away.
Rectangle {
    id: root
    property alias text: input.text
    property string placeholder: ""
    property bool monospace: false
    signal accepted(string text)
    signal edited(string text)

    width: parent ? parent.width : 260
    height: 32
    radius: 8
    color: Qt.rgba(Config.foreground.r, Config.foreground.g, Config.foreground.b, 0.08)
    border.width: input.activeFocus ? 2 : 1
    border.color: input.activeFocus ? Config.accent : Qt.rgba(Config.foreground.r, Config.foreground.g, Config.foreground.b, 0.12)

    TextInput {
        id: input
        anchors.fill: parent
        anchors.leftMargin: 10
        anchors.rightMargin: 10
        verticalAlignment: TextInput.AlignVCenter
        color: Config.foreground
        selectionColor: Config.accent
        selectedTextColor: "#ffffff"
        font.pixelSize: Config.fontSize
        font.family: root.monospace ? "monospace" : (Config.fontFamily !== "" ? Config.fontFamily : Qt.application.font.family)
        clip: true
        selectByMouse: true
        onEditingFinished: root.accepted(text)
        onTextEdited: root.edited(text)
    }
    PillText {
        anchors.fill: parent
        anchors.leftMargin: 10
        visible: input.text === "" && !input.activeFocus
        text: root.placeholder
        color: Config.subtle
    }
}
