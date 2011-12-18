import QtQuick 1.0
import com.nokia.symbian 1.0

CommonDialog {
    id: loginDialog
    titleText: qsTr("Login to ") + (service == "READ_IT_LATER"? qsTr("Read It Later") : qsTr("Instapaper") )

    property string service: ""
    property string loginId: ""
    property string pwd: ""
    property string shareurl: ""
    property string sharetitle: ""
    property bool saveLogin: false

    content: Column {
        width: parent.width - 2*platformStyle.paddingMedium
        height: loginIdText.height + pwdText.height + saveLoginCheckbox.height + 3*platformStyle.paddingMedium
        spacing: platformStyle.paddingMedium
        anchors {
            top: parent.top
            left: parent.left
            margins: platformStyle.paddingMedium
        }
        TextField {
            placeholderText: qsTr("Login Id")
            id: loginIdText
            text: loginId
            width: parent.width
        }
        TextField {
            placeholderText: qsTr("Password")
            id: pwdText
            text: pwd
            width: parent.width
            echoMode: TextInput.Password
        }
        CheckBox {
            id: saveLoginCheckbox
            text: qsTr("Save Login Information")
            checked: saveLogin
        }
    }

    buttons: ButtonRow  {
        width: parent.width - 2*platformStyle.paddingMedium
        height: readLaterDialogSendButton.height + platformStyle.paddingMedium
        anchors {
            top: parent.top
            left: parent.left
            margins: platformStyle.paddingMedium
        }
        Button {
            id: readLaterDialogSendButton
            text: qsTr("Send")
            onClicked: {
                loginDialog.close()
                if(loginIdText.text != undefined && loginIdText.text != "") {
                    feedItemPage.callSentToReadLater(service, loginIdText.text, pwdText.text, loginDialog.sharetitle, loginDialog.shareurl)
                    if(saveLoginCheckbox.checked) feedItemPage.saveAuthData(service, loginIdText.text, pwdText.text)
                }
            }
        }
        Button {
            text: qsTr("Cancel")
            onClicked: loginDialog.close()
        }
    }
    onClickedOutside: loginDialog.close()
}

