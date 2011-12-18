import QtQuick 1.0
import com.nokia.symbian 1.0

CommonDialog {
    id: moveFeedDialog
    titleText: qsTr("Add Feed to Folder")

    property ListModel model
    model: ListModel {
        id: selectTagListModel
    }
    property string currFoldersStr: ""
    property string feedId: ""
    property string feedTitle: ""

    width: parent.width// - 2*platformStyle.paddingMedium
    height: window.inPortrait ? screen.height*0.8 : screen.height

    content: Column {
        width: parent.width
        height: parent.height
        spacing: platformStyle.paddingMedium
        anchors {
            left: parent.left
            top: parent.top
            margins: platformStyle.paddingMedium
        }

        Row {
            id: goButtonRow
            width: parent.width// - 2*platformStyle.paddingMedium
            spacing: platformStyle.paddingMedium
            z: 2
            TextField {
                id: newFolderText
                placeholderText: qsTr("Enter New Folder Name")
                width: goButtonRow.width - goButton.width - 3*platformStyle.paddingMedium
            }
            Button {
                id: goButton
                text: qsTr("Go")
                onClicked: {
                    subscrListPage.itemOptions(moveFeedDialog.feedId, newFolderText.text, "move", moveFeedDialog.feedTitle)
                    moveFeedDialog.close()
                }
            }
        }

        ListView {
            id: selectFolderListView
            clip: true
            width: parent.width
            height: parent.height - goButtonRow.height

            model: moveFeedDialog.model

            delegate: ListItem {
                id: tagListItem
                width: selectFolderListView.width
                implicitHeight: feedNewParentCb.height + 2*platformStyle.paddingMedium
                Row {
                    width: parent.width
                    //anchors.fill: tagListItem.paddingItem
                    anchors {
                        top: tagListItem.top
                        left: tagListItem.left
                        margins: platformStyle.paddingMedium
                    }
                    spacing: platformStyle.paddingMedium

                    CheckBox {
                        id: feedNewParentCb
                        checked: selected
                        onClicked: {
                            //console.log("Clicked on "+name+" current selection status:"+checked)
                            addRemoveFolder(moveFeedDialog.feedId, moveFeedDialog.feedTitle)
                        }
                    }

                    ListItemText {
                        text: name
                        anchors.verticalCenter: feedNewParentCb.verticalCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }
                onClicked: { feedNewParentCb.checked = !feedNewParentCb.checked; addRemoveFolder(moveFeedDialog.feedId, moveFeedDialog.feedTitle) }

                function addRemoveFolder(feedId, feedTitle) {
                    if(selected != feedNewParentCb.checked) {
                        subscrListPage.itemOptions(feedId, name, feedNewParentCb.checked ? "move" : "remove", feedTitle)
                        selectFolderListView.model.setProperty(index, "selected", feedNewParentCb.checked)
                    }
                }
            }
        }
    }

    buttons: ButtonRow  {
        width: parent.width - 2*platformStyle.paddingMedium
        height: moveFeedDialogButtonClose.height + platformStyle.paddingMedium
        anchors {
            top: parent.top
            left: parent.left
            margins: platformStyle.paddingMedium
        }
        Button {
            id: moveFeedDialogButtonClose
            text: qsTr("Close")
            onClicked: moveFeedDialog.close()
        }
    }
    onClickedOutside: moveFeedDialog.close()
}
