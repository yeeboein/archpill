import QtQuick
import qs
import qs.components

// Drag-to-reorder list. Grab the ⠿ handle and drag up/down, or use the
// arrow buttons. × removes an item. Emits `changed(newList)`.
Item {
    id: root

    property var items: []
    property var labelFor: id => id
    property var iconFor: id => "star"
    property var noteFor: id => ""
    property string emptyText: "Nothing here yet - add something below."
    signal changed(var newItems)

    readonly property int rowH: 46
    property int dragFrom: -1
    property int dragTo: -1

    width: parent ? parent.width : 400
    implicitHeight: Math.max(items.length * rowH, 40)

    function moveItem(from, to) {
        if (from === to || from < 0 || to < 0 || to >= items.length)
            return;
        const l = items.slice();
        const it = l.splice(from, 1)[0];
        l.splice(to, 0, it);
        changed(l);
    }
    function removeAt(i) {
        const l = items.slice();
        l.splice(i, 1);
        changed(l);
    }
    // Where row i should sit while something is being dragged.
    function slotY(i) {
        if (dragFrom < 0 || i === dragFrom)
            return i * rowH;
        if (dragFrom < dragTo && i > dragFrom && i <= dragTo)
            return (i - 1) * rowH;
        if (dragFrom > dragTo && i < dragFrom && i >= dragTo)
            return (i + 1) * rowH;
        return i * rowH;
    }

    PillText {
        visible: root.items.length === 0
        anchors.centerIn: parent
        text: root.emptyText
        color: Config.subtle
    }

    Repeater {
        model: root.items
        delegate: Item {
            id: row
            required property var modelData
            required property int index
            readonly property bool dragging: root.dragFrom === index

            width: root.width
            height: root.rowH
            y: root.slotY(index)
            z: dragging ? 10 : 0
            Behavior on y {
                enabled: !row.dragging
                NumberAnimation {
                    duration: 120
                    easing.type: Easing.OutCubic
                }
            }

            Rectangle {
                anchors.fill: parent
                anchors.topMargin: 3
                anchors.bottomMargin: 3
                radius: 12
                color: row.dragging ? Qt.rgba(Config.accent.r, Config.accent.g, Config.accent.b, 0.3) : Qt.rgba(Config.foreground.r, Config.foreground.g, Config.foreground.b, 0.07)
                border.width: row.dragging ? 1 : 0
                border.color: Config.accent

                Icon {
                    id: handleIcon
                    x: 8
                    anchors.verticalCenter: parent.verticalCenter
                    name: "drag"
                    size: 18
                    color: Config.subtle
                }
                Icon {
                    id: itemIcon
                    anchors.left: handleIcon.right
                    anchors.leftMargin: 8
                    anchors.verticalCenter: parent.verticalCenter
                    name: root.iconFor(row.modelData)
                    size: 16
                }
                Column {
                    anchors.left: itemIcon.right
                    anchors.leftMargin: 10
                    anchors.right: buttons.left
                    anchors.rightMargin: 8
                    anchors.verticalCenter: parent.verticalCenter
                    PillText {
                        width: parent.width
                        text: root.labelFor(row.modelData)
                    }
                    PillText {
                        width: parent.width
                        visible: text !== ""
                        text: root.noteFor(row.modelData)
                        color: Config.subtle
                        sizeFactor: 0.8
                    }
                }
                Row {
                    id: buttons
                    anchors.right: parent.right
                    anchors.rightMargin: 4
                    anchors.verticalCenter: parent.verticalCenter
                    IconButton {
                        icon: "arrow-up"
                        size: 16
                        enabledAction: row.index > 0
                        onClicked: root.moveItem(row.index, row.index - 1)
                    }
                    IconButton {
                        icon: "arrow-down"
                        size: 16
                        enabledAction: row.index < root.items.length - 1
                        onClicked: root.moveItem(row.index, row.index + 1)
                    }
                    IconButton {
                        icon: "close"
                        size: 14
                        onClicked: root.removeAt(row.index)
                    }
                }

                // Drag handle (also the icon + name area).
                MouseArea {
                    anchors.left: parent.left
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    anchors.right: buttons.left
                    cursorShape: pressed ? Qt.ClosedHandCursor : Qt.OpenHandCursor
                    preventStealing: true
                    drag.target: row
                    drag.axis: Drag.YAxis
                    drag.minimumY: 0
                    drag.maximumY: Math.max(0, (root.items.length - 1) * root.rowH)
                    onPressed: {
                        root.dragFrom = row.index;
                        root.dragTo = row.index;
                    }
                    onPositionChanged: {
                        if (drag.active)
                            root.dragTo = Math.max(0, Math.min(root.items.length - 1, Math.round(row.y / root.rowH)));
                    }
                    onReleased: {
                        const from = root.dragFrom, to = root.dragTo;
                        root.dragFrom = -1;
                        root.dragTo = -1;
                        row.y = Qt.binding(() => root.slotY(row.index));
                        root.moveItem(from, to);
                    }
                }
            }
        }
    }
}
