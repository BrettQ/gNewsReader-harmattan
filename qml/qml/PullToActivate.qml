import QtQuick 1.0

Item {
    id: root
    property ListView myListView
    property bool isHorizontal : true
    property bool isHeader : true
    property bool reloadTriggered

    property int indicatorStart: 160
    property int refreshStart: 180
    property int timerDelay: 1000

    signal refresh()

    width: screen.width
    height: 0

    Image {
        visible: isHorizontal
        anchors.bottom: root.isHeader ? parent.top : undefined
        anchors.top: root.isHeader ? undefined : parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottomMargin: root.isHeader ? platformStyle.paddingLarge : 0
        anchors.topMargin: root.isHeader ? 0 : platformStyle.paddingLarge
        source:  "../pics/tb_reload.svg"
        opacity: (root.isHeader ? -myListView.contentY : myListView.contentY - myListView.parent.contentY ) > root.indicatorStart ? 1 : 0;
        Behavior on opacity { NumberAnimation { duration: 100  } }
        rotation: {
            var newAngle = root.isHeader ? -myListView.contentY : myListView.contentHeight - myListView.parent.contentY
            if (newAngle > root.refreshStart) {
                myListTimer.start();
                return -180;
            } else {
                newAngle = newAngle > 180 ? 180 : 0;
                return -newAngle;
            }
        }
        Behavior on rotation { NumberAnimation { duration: 150 } }
    }

    Timer {
        id: myListTimer
        interval: root.timerDelay; running: false; repeat: false
        onTriggered: root.refresh()
    }
}
