import QtQuick 1.0
import com.nokia.symbian 1.0

CommonDialog {
    id: subFeedDialog
    titleText: qsTr("Add New Feed to Google Reader")

    property string feedUrl: ""
    property string feedFolder: ""

    content: Column {
        width: parent.width - 2*platformStyle.paddingMedium
        height: feedUrlText.height + feedTitleText.height + 3*platformStyle.paddingMedium
        spacing: platformStyle.paddingMedium
        anchors {
            top: parent.top
            left: parent.left
            margins: platformStyle.paddingMedium
        }
        TextField {
            placeholderText: qsTr("Feed URL/Search Term")
            id: feedUrlText
            text: feedUrl
            width: parent.width
        }
        TextField {
            placeholderText: qsTr("Title (Optional)")
            id: feedTitleText
            text: feedFolder
            width: parent.width
        }
    }

    buttons: ButtonRow  {
        width: parent.width - 2*platformStyle.paddingMedium
        height: addNewFeedDialogButtonOk.height + platformStyle.paddingMedium
        anchors {
            top: parent.top
            left: parent.left
            margins: platformStyle.paddingMedium
        }
        Button {
            id: addNewFeedDialogButtonOk
            iconSource: "../../pics/tb_ok.svg"
            onClicked: {
                if(feedUrlText.text != undefined && feedUrlText.text != "") {
                    if(/(http|https):\/\/(\w+:{0,1}\w*@)?(\S+)(:[0-9]+)?(\/|\/([\w#!:.?+=&%@!\-\/]))?/.test(feedUrlText.text)) {
                    subscrListPage.itemOptions("feed/"+feedUrlText.text, -1, "subscribe", feedTitleText.text)
                    subFeedDialog.close()
                    } else {
                        subscrListPage.searchForFeed(feedUrlText.text); subFeedDialog.close()
                    }
                }
            }
        }
//                Button {
//                    iconSource: "../pics/tb_search.svg"
//                    onClicked: { subscrListPage.searchForFeed(feedUrlText.text); subFeedDialog.close() }
//                }
        Button {
            iconSource: "../../pics/tb_paste.svg"
            onClicked: feedUrlText.paste()
        }
        Button {
            iconSource: "../../pics/tb_close_stop.svg"
            onClicked: subFeedDialog.close()
        }
    }
    onClickedOutside: { subFeedDialog.close() }
}
