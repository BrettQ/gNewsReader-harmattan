import QtQuick 1.0
import com.nokia.symbian 1.0

CommonDialog {
    id: edittagsDialog
    titleText: qsTr("Add or Edit Tags")
    //height: editTagsCenterColumn.height + editTagsButtonRow.height + 3*platformStyle.paddingMedium
    property string origTags: feedItemPage.getCurrentFeed() != null ? feedItemPage.getCurrentFeed().categoriesStr : ""

    content: Column {
        id: editTagsCenterColumn
        width: parent.width - 2*platformStyle.paddingMedium
        height: editTagsDialogTextLabel.height + tagText.height + 3*platformStyle.paddingMedium
        spacing: platformStyle.paddingMedium
        anchors {
            top: parent.top
            left: parent.left
            margins: platformStyle.paddingMedium
        }
        ListItemText {
            id: editTagsDialogTextLabel
            text: qsTr("Separate Tags by commas")
            role: "Subtitle"
        }

        TextField {
            placeholderText: qsTr("Enter tags here")
            id: tagText
            text: currentTags
            width: parent.width
        }
    }

    buttons: ButtonRow  {
        id: editTagsButtonRow
        width: parent.width - 2*platformStyle.paddingMedium
        height: btnEditTagsSave.height + platformStyle.paddingMedium
        anchors {
            top: parent.top
            left: parent.left
            margins: platformStyle.paddingMedium
        }
        Button {
            id: btnEditTagsSave
            text: qsTr("Save")
            onClicked: {
                edittagsDialog.close()
                if((tagText.text != undefined && tagText.text != "") ||
                        (tagText.text =="" && edittagsDialog.origTags != undefined && edittagsDialog.origTags != "")) {
                    feedItemPage.saveTags(tagText.text, origTags) //Call edit tag action
                    //feedItemPage.categoriesStr = tagText.text
                }
            }
        }
        Button {
            text: qsTr("Cancel")
            onClicked: edittagsDialog.close()
        }
    }
    onClickedOutside: edittagsDialog.close()
    Component.onCompleted: { tagText.text = feedItemPage.getCurrentFeed().categoriesStr }
}
