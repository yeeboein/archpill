import QtQuick
import qs
import qs.components

// One setting: name + explanation on the left, the control on the right.
Item {
    id: root
    property string label: ""
    property string description: ""
    default property alias control: slot.data
    property int controlWidth: 260

    width: parent ? parent.width : 400
    implicitHeight: Math.max(48, texts.implicitHeight + 16, slot.childrenRect.height + 16)

    Column {
        id: texts
        anchors.left: parent.left
        anchors.right: slot.left
        anchors.rightMargin: 16
        anchors.verticalCenter: parent.verticalCenter
        PillText {
            width: parent.width
            text: root.label
        }
        PillText {
            width: parent.width
            visible: text !== ""
            text: root.description
            color: Config.subtle
            sizeFactor: 0.85
            wrapMode: Text.Wrap
            maximumLineCount: 3
        }
    }
    Item {
        id: slot
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        width: root.controlWidth
        height: childrenRect.height
    }
}
