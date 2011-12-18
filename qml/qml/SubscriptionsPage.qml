/*
    Copyright 2011 - Yogeshwar Padhyegurjar

    This file is part of gNewsReader.

    gNewsReader is free software: you can redistribute it and/or modify
    it under the terms of the GNU Lesser General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    gNewsReader is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Lesser General Public License for more details.

    You should have received a copy of the GNU Lesser General Public License
    along with gNewsReader. If not, see <http://www.gnu.org/licenses/>.
*/

import QtQuick 1.0
import com.nokia.symbian 1.0

Page {
    id: subscrListPage
    property ListModel model
    property bool mainCompVisible : (subscrListPage.model != null && subscrListPage.model.count > 0)

    signal folderClicked(int index, string folderId, bool expanded)
    signal itemClicked( string itemId, string feedTitle )
    signal longPressMenu (string inId, string inTitle, int index, bool isHeader, string cat, string allcategories)
    signal itemOptions( string itemId, string listIndex, string menuId, string feedTitle )
    signal showSubDialog(string feed, string title)
    signal searchForFeed(string query)

    signal takeToTop()
    signal takeFocus()
    onTakeToTop: if(subCompLoader.item != null) subCompLoader.item.takeToTop()
    onTakeFocus: if(subCompLoader.item != null) subCompLoader.item.takeFocus()
    onStatusChanged: {
        //if(status == PageStatus.Activating) {if (subCompLoader.sourceComponent == undefined) {subCompLoader.sourceComponent = subListComponent;} }
        if(status == PageStatus.Active) { topMsgText.text=qsTr("Subscriptions"); subCompLoader.item.takeFocus() }
        //if(status == PageStatus.Inactive) subCompLoader.sourceComponent = undefined
    }
    onShowSubDialog: { var addNewFeedComp = Qt.createComponent("components/AddNewFeedDialog.qml"); addNewFeedComp.createObject(subscrListPage).open()}//subFeedDialogComp.createObject(subscrListPage).open()

    onLongPressMenu: {
        //var optionMenu = itemOptionMenuComp.createObject(subscrListPage)
        var optionMenu = Qt.createComponent("components/SubItemOptionsMenu.qml").createObject(subscrListPage)
        optionMenu.itemIndex = index; optionMenu.feedId = inId; optionMenu.feedTitle = inTitle; optionMenu.isSection = isHeader; optionMenu.category = cat; optionMenu.allcats = allcategories
        optionMenu.open()
    }

    Loader {
        id: subCompLoader
        sourceComponent: subListComponent //undefined
        anchors { fill: parent; margins: 0 }
        focus: true
    }

    Component {
        id:subListComponent
        Rectangle {
            id: sublistItem
            focus: true
            color: window.useLightTheme ? "#f2f2f2" : platformStyle.colorNormalDark
            signal takeToTop()
            signal takeFocus()
            onTakeToTop: subListView.positionViewAtIndex(0, ListView.Beginning)
            onTakeFocus: subListView.forceActiveFocus()

            ListView {
                id: subListView
                focus: true
                delegate: listDelegate
                anchors { fill: parent; margins: 0 }
                model: subscrListPage.model
                visible: subscrListPage.mainCompVisible
                highlightFollowsCurrentItem: true
            }
            ScrollDecorator {
                id: subscrolldecorator
                flickableItem: subListView
            }
//            ScrollBar {
//                id: vertical
//                flickableItem: subListView
//                orientation: Qt.Vertical
//                anchors { right: subListView.right; top: subListView.top }
//            }
            Component.onCompleted: { subListView.forceActiveFocus(); subListView.currentIndex = 0 }
        } 
    }

    Component {
        id: listDelegate
        ListItemG {
            id: sublistItem
            //visible: count > 0
            width: subListView.width
            height: subItemTitle.height + 2*platformStyle.paddingLarge
            //platformInverted: window.useLightTheme

            BorderImage {
                visible: !sub && sublistItem.mode == "normal"
                source: window.useLightTheme?"../pics/list_default_inverse.svg":"../pics/list_default.svg"
                border { left: 0; top: 0; right: 0; bottom: 0 }
                smooth: false
                anchors.fill: parent
            }

            Row {
                id: subRow
                width: parent.width
                anchors.fill: sublistItem.paddingItem
                spacing: platformStyle.paddingMedium

                Image {
                    id: itemImage
                    asynchronous: true
                    visible: sub
                    source: window.useLightTheme?"../pics/tb_feed_inverse.svg":"../pics/tb_feed.svg"
                    sourceSize.height: platformStyle.graphicSizeSmall
                    sourceSize.width: platformStyle.graphicSizeSmall
                    anchors.verticalCenter: subItemTitle.verticalCenter
                }

                Image {
                    id: tagImage
                    asynchronous: true
                    visible: cat === "tag"
                    property bool isExpanded: true
                    source: window.useLightTheme?"../pics/tb_tag_inverse.svg":"../pics/tb_tag.svg"
                    sourceSize.height: platformStyle.graphicSizeSmall
                    sourceSize.width: platformStyle.graphicSizeSmall
                    anchors.verticalCenter: subItemTitle.verticalCenter
                }

                Image {
                    id: folderImage
                    asynchronous: true
                    visible: cat === "folder"
                    property bool isExpanded: true
                    source: window.useLightTheme?"../pics/tb_folder_inverse.svg":"../pics/tb_folder.svg"
                    sourceSize.height: platformStyle.graphicSizeSmall
                    sourceSize.width: platformStyle.graphicSizeSmall
                    anchors.verticalCenter: subItemTitle.verticalCenter
                    MouseArea {
                        enabled: cat == "folder"
                        anchors.fill: parent
                        onClicked: { subscrListPage.folderClicked(index, itemId, folderImage.isExpanded); folderImage.isExpanded = !folderImage.isExpanded; }
                    }
                }

                ListItemTextG {
                    id: subItemTitle
                    mode: sublistItem.mode
                    platformInverted: window.useLightTheme
                    font.pixelSize: sub ? window.fontSizeMedium : window.fontSizeLarge
                    text: title
                    width: (parent.width - itemImage.width - subItemCount.width - 2*platformStyle.paddingLarge)
                    verticalAlignment: Text.AlignVCenter
                }

                ListItemTextG {
                    id: subItemCount
                    mode: sublistItem.mode
                    platformInverted: window.useLightTheme
                    role: "Heading"
                    text: count
                    horizontalAlignment: Text.AlignRight
                    verticalAlignment: Text.AlignVCenter
                }
            }
            onClicked: if(itemId != "zzunknown") subscrListPage.itemClicked(itemId, title)
            onPressAndHold: subscrListPage.longPressMenu(itemId, title, index, !sub, cat, allcategories)
        }
    }
}
