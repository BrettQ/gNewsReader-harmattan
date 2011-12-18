import QtQuick 1.0
import com.nokia.symbian 1.0

CommonDialog {
    id: editDialog
    titleText: qsTr("Rename Feed")

    property string editTitle: ""
    property string editFeedId: ""
    property string category: ""

    content: Column {
        width: parent.width - 2*platformStyle.paddingMedium
        //height: editDialogText.height + 2*platformStyle.paddingMedium
        spacing: platformStyle.paddingMedium
        anchors {
            top: parent.top
            left: parent.left
            margins: platformStyle.paddingMedium
        }
        TextField {
            id: editDialogText
            text: editTitle
            width: parent.width
        }
    }

    buttons: ButtonRow  {
        width: parent.width - 2*platformStyle.paddingMedium
        height: renameDialogButtonOk.height + platformStyle.paddingMedium
        anchors {
            top: parent.top
            left: parent.left
            margins: platformStyle.paddingMedium
        }
        Button {
            id: renameDialogButtonOk
            text: qsTr("Ok")
            onClicked: {
                editDialog.close()
                if(editDialogText.text != undefined && editDialogText.text != "") {
                    category == "sub" ? subscrListPage.itemOptions(editFeedId, -1, "edit", editDialogText.text)
                                      : subscrListPage.itemOptions(editFeedId, -1, "rename", editDialogText.text)
                }
            }
        }
        Button {
            text: qsTr("Cancel")
            onClicked: editDialog.close()
        }
    }
    onClickedOutside: editDialog.close()
}
