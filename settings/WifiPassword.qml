import QtQuick
import Quickshell
import qs
import qs.components
import qs.services

// Small window that asks for a Wi-Fi password (the pill itself never takes
// keyboard input, so typing happens here).
FloatingWindow {
    id: win
    title: "Wi-Fi password"
    implicitWidth: 380
    implicitHeight: 190
    color: Qt.rgba(Config.background.r, Config.background.g, Config.background.b, 1)

    readonly property string ssid: PillState.wifiPasswordFor
    property bool show: false

    function connect() {
        if (box.text.length === 0)
            return;
        Network.connectWithPassword(ssid, box.text);
        PillState.wifiPasswordFor = "";
    }

    onClosed: PillState.wifiPasswordFor = ""

    Column {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 12

        Row {
            spacing: 10
            Icon {
                anchors.verticalCenter: parent.verticalCenter
                name: "lock"
                size: 20
                color: Config.accent
            }
            PillText {
                anchors.verticalCenter: parent.verticalCenter
                text: "Connect to \"" + win.ssid + "\""
                font.weight: Font.Bold
                sizeFactor: 1.15
                width: 300
            }
        }
        Row {
            width: parent.width
            spacing: 8
            TextBox {
                id: box
                width: parent.width - showBtn.width - 8
                placeholder: "Password"
                echoMode: win.show ? TextInput.Normal : TextInput.Password
                inputFocus: true
                onSubmitted: win.connect()
            }
            SmallButton {
                id: showBtn
                anchors.verticalCenter: parent.verticalCenter
                label: win.show ? "Hide" : "Show"
                onClicked: win.show = !win.show
            }
        }
        Row {
            anchors.right: parent.right
            spacing: 8
            SmallButton {
                label: "Cancel"
                onClicked: PillState.wifiPasswordFor = ""
            }
            SmallButton {
                label: "Connect"
                highlight: true
                enabled: box.text.length > 0
                onClicked: win.connect()
            }
        }
    }
}
