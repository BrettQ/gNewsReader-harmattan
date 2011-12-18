import QtQuick 1.0
import com.nokia.symbian 1.0
import "../../js/OAuthConstants.js" as Const

ContextMenu {
    id: itemOptionMenu
    property string feedId: ""
    property int itemIndex: -1
    property string feedTitle: ""
    property bool isSection: false
    property string category: ""
    property string allcats: ""

    MenuLayout {
        MenuItem {
            ListItemText {
                text: itemOptionMenu.feedTitle
                color: platformStyle.colorNormalLink
                anchors {
                    left: parent.left
                    leftMargin: platformStyle.paddingLarge
                    top: parent.top
                    bottom: parent.bottom
                }
                width: itemOptionMenu.width
                elide: Text.ElideRight
                verticalAlignment: Text.AlignVCenter
            }
            enabled: false
        }
        MenuItem {
            text: qsTr("Unsubscribe")
            visible: !isSection
            onClicked: subscrListPage.itemOptions(itemOptionMenu.feedId, itemOptionMenu.itemIndex, "unsubscribe", itemOptionMenu.feedTitle)
        }
        MenuItem {
            text: qsTr("Mark All as Read")
            onClicked: subscrListPage.itemOptions(itemOptionMenu.feedId, itemOptionMenu.itemIndex, "markAll", itemOptionMenu.feedTitle)
        }
        MenuItem {
            text: qsTr("Rename")
            visible: !(category == "folder")
            onClicked: {
                var dialog = Qt.createComponent("RenameFeedDialog.qml").createObject(subscrListPage)//renameFeedDialog.createObject(subscrListPage)
                dialog.editFeedId = itemOptionMenu.feedId; dialog.editTitle = itemOptionMenu.feedTitle; dialog.category = category
                dialog.open()
            }
        }
        MenuItem {
            text: qsTr("Delete")
            visible: category == "tag"
            onClicked: subscrListPage.itemOptions(itemOptionMenu.feedId, itemOptionMenu.itemIndex, "delete", itemOptionMenu.feedTitle)
        }
        MenuItem {
            text: qsTr("Move to Folder")
            visible: category == "sub"
            onClicked: {
                var dialog = Qt.createComponent("MoveFeedDialog.qml").createObject(subscrListPage)
                dialog.feedId = itemOptionMenu.feedId; dialog.feedTitle = itemOptionMenu.feedTitle; dialog.currFoldersStr = allcats
                console.log(allcats)
                if(allcats != null && allcats != undefined && allcats != "zzunknown") {
                    var selectedCats = JSON.parse(allcats); var currCat = null
                    for(var i in selectedCats) dialog.model.append({"name": selectedCats[i].label, "tagid":selectedCats[i].id, "selected": true})
                }
                for(var prop in Const.Tags) {
                    if( prop.indexOf("/label/") != -1 && allcats.indexOf(prop) == -1) dialog.model.append({"name": Const.Tags[prop].label, "tagid":prop, "selected": false})
                }
                dialog.open()
            }
        }
    }
}



