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
import QtWebKit 1.0
import com.nokia.symbian 1.0

import "../js/OAuthConstants.js" as Const

Page {
    id: feedItemPage

    property ListModel model

    property int index : 0
    property int startIndex: 0
    property bool mainCompVisible : true

    property string feedId: ""
    property string feedUrl: ""

    signal loadNext()
    signal loadPrev()

    signal backToList()
    signal takeToTop()
    signal takeFocus()
    signal showEditTagDialog()
    signal saveTags(string tagsToSave, string originalTags)

    signal showReadItLaterSignIn(string inService, string shareTitle, string shareUrl)
    signal callSentToReadLater(string inSvc, string inUser, string inPwd, string inTitle, string inUrl)
    signal saveAuthData(string service, string inUser, string inPwd)

    signal markFeedAsRead(int feedindex, bool replacePage)

    function getCurrentFeed() {
        if(compLoader.item != null) return compLoader.item.getCurrentFeed()
        else return null
    }

    function setCurrentFeedProperty(propName, propVal) {
        if(compLoader.item != null) compLoader.item.setCurrentFeedProperty(propName, propVal)
    }

    onShowReadItLaterSignIn: {
        var dialog = Qt.createComponent("components/ReadLaterLoginDialog.qml").createObject(feedItemPage)
        dialog.service = inService; dialog.shareurl = shareUrl; dialog.sharetitle = shareTitle
        dialog.open()
    }
    onTakeToTop: if(compLoader.item != null) compLoader.item.takeToTop()
    onTakeFocus: if(compLoader.item != null) compLoader.item.takeFocus()
    onLoadNext: if(compLoader.item != null) compLoader.item.loadNext()
    onLoadPrev: if(compLoader.item != null) compLoader.item.loadPrev()
    onStatusChanged: {
        if(status == PageStatus.Activating) {if (compLoader.sourceComponent == undefined) compLoader.sourceComponent = feedItemComponent }
        if(status == PageStatus.Active) { if(feedItemPage.model != null && feedItemPage.model != undefined) topMsgText.text = (feedItemPage.index+1) + qsTr(" of ") + feedListModel.count }
        if(status == PageStatus.Inactive) compLoader.sourceComponent = undefined
    }
    onShowEditTagDialog: {
        var dialog = Qt.createComponent("components/EditTagsDialog.qml").createObject(feedItemPage)
        dialog.open()
    }

    Loader {
        id: compLoader
        sourceComponent: undefined
        anchors { fill: parent; margins: 0 }
        focus: true
    }

    Component {
        id:feedItemComponent

        Item {
            id: feedItemRect
            anchors.fill: parent
            focus: true

//            signal takeToTop()
            signal scrollView(bool isUp, int byPixels)
            signal takeFocus()
            signal setCurrentIndex(int currIndex)
            signal loadNext()
            signal loadPrev()

//            onTakeToTop: { feedItemFlickable.contentX = 0; feedItemFlickable.contentY = 0 }
            onTakeFocus: feedItemRect.forceActiveFocus()
            onScrollView: view.currentItem.scrollView(isUp, byPixels)
            onSetCurrentIndex: view.currentIndex = currIndex
            onLoadNext: { view.moveToNext() }
            onLoadPrev: { view.moveToPrev() }

            function getCurrentFeed() {
                return view.model.get(view.currentIndex)
            }

            function setCurrentFeedProperty(propName, propVal) {
                view.model.setProperty(view.currentIndex, propName, propVal)
            }

            Keys.onPressed: {
//                if (event.key == Qt.Key_Right) {
//                    feedItemRect.loadNext()
//                }
//                if (event.key == Qt.Key_Left) {
//                    feedItemRect.loadPrev()
//                }
                if (event.key == Qt.Key_Backspace) {
                    feedItemPage.backToList()
                }
                if (event.key == Qt.Key_Up) {
                    scrollView(true, platformStyle.graphicSizeLarge)
                }
                if (event.key == Qt.Key_Down) {
                    scrollView(false, platformStyle.graphicSizeLarge)
                }
            }

            Component.onCompleted: { view.currentItem.forceActiveFocus(); view.positionViewAtIndex(feedItemPage.startIndex, ListView.Beginning); view.currentItem.setInterActive(true) }

            ListView {
                id: view
                signal moveToNext()
                signal moveToPrev()
                onMoveToNext: { incrementCurrentIndex(); currentItem.setInterActive(true)/*; currentItem.markAsRead()*/ }
                onMoveToPrev: { decrementCurrentIndex(); currentItem.setInterActive(true)/*; currentItem.markAsRead()*/ }
                onCurrentIndexChanged: { topMsgText.text = (currentIndex+1) + qsTr(" of ") + feedListModel.count; feedItemPage.index = currentIndex; currentItem.markAsRead() }
                anchors.fill: parent
                model: feedItemPage.model
                interactive: window.swipeGestureEnabled && !currentItem.isMoving
                orientation: ListView.Horizontal
                snapMode: ListView.SnapOneItem
                flickDeceleration: 500
                cacheBuffer: width
                delegate: feedViewDelegate
                boundsBehavior: Flickable.DragOverBounds
                flickableDirection:Flickable.HorizontalFlick
                onMovementStarted: currentItem.setInterActive(false)
                onMovementEnded: { currentItem.setInterActive(true)/*; currentItem.markAsRead()*/ }
                onFlickEnded: currentItem.setInterActive(true)
                //pressDelay: 1000

                preferredHighlightBegin: 0; preferredHighlightEnd: 0  //this line means that the currently highlighted item will be central in the view
                highlightRangeMode: ListView.StrictlyEnforceRange  //this means that the currentlyHighlightedItem will not be allowed to leave the view
                highlightFollowsCurrentItem: true  //updates the current index property to match the currently highlighted item
                highlightMoveSpeed: 1200
            }

            Component {
                id: feedViewDelegate

                Item {
                    id: feedPathItemRect
                    width: feedItemRect.width
                    height: feedItemRect.height
                    clip: true
                    property bool isMoving : feedItemFlickable.movingVertically

                    signal setInterActive(bool flag)
                    onSetInterActive: { feedItemFlickable.interactive = flag; summary.settings.autoLoadImages = (flag && window.autoLoadImages) }
                    signal markAsRead()
                    onMarkAsRead: if(!readstatus) feedItemPage.markFeedAsRead(index, false)
                    signal scrollView(bool isUp, int byPixels)
                    onScrollView: {
                        if(isUp) feedItemFlickable.contentY = Math.max(0,  feedItemFlickable.contentY - byPixels)
                        else feedItemFlickable.contentY = Math.min(feedItemFlickable.contentHeight - feedItemFlickable.height, feedItemFlickable.contentY + byPixels)
                    }

                    Flickable {
                        id: feedItemFlickable
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        anchors.left: parent.left
                        anchors.right: parent.right
                        interactive: false
                        width: parent.width
                        height: feedItemRect.height
                        contentWidth: summary.width
                        contentHeight: summary.height + feedTitleRect.height
                        boundsBehavior : Flickable.StopAtBounds
                        flickableDirection: window.swipeGestureEnabled ? Flickable.VerticalFlick : Flickable.HorizontalAndVerticalFlick

                        Rectangle {
                            id: feedTitleRect
                            width: parent.width
                            height: feedItemTitleBar.height + 2*platformStyle.paddingMedium
                            color: window.useLightTheme? "#E6E6E6" : platformStyle.colorNormalDark

                            Column {
                                id: feedItemTitleBar
                                width: feedItemRect.width - 2*platformStyle.paddingMedium
                                spacing: platformStyle.paddingSmall

                                anchors {
                                    left: feedTitleRect.left
                                    top: feedTitleRect.top
                                    margins: platformStyle.paddingMedium
                                }

                                Text {
                                    id: feedItemTitle
                                    width:  parent.width
                                    font.bold: true
                                    color: window.useLightTheme ? "#282828" : platformStyle.colorNormalLight
                                    font.pixelSize: window.fontSizeLarge
                                    wrapMode: Text.Wrap
                                    text: title//pageTitle
                                }

                                Item {
                                    id: feedHeaderRect
                                    width: parent.width - 2*platformStyle.paddingMedium
                                    height: Math.max(feedSource.height, feedDate.height)

                                    Row {
                                        spacing: platformStyle.paddingMedium
                                        Text {
                                            id: feedSource
                                            color: window.useLightTheme? "#666666" : platformStyle.colorNormalMid
                                            font.pixelSize: window.fontSizeSmall
                                            width: feedHeaderRect.width - dateIconRow.width
                                            text: source//pageSource
                                            wrapMode: Text.Wrap
                                        }

                                        Row {
                                            id: dateIconRow

                                            Text {
                                                id: feedDate
                                                color: window.useLightTheme? "#666666" : platformStyle.colorNormalMid
                                                font.pixelSize: window.fontSizeSmall
                                                text: Const.humaneDate(feedTime*1)//Const.humaneDate(formattedDate*1)
                                                wrapMode: Text.Wrap
                                                horizontalAlignment: Text.AlignRight
                                            }
                                            Image {
                                                asynchronous: true
                                                source: window.useLightTheme?"../pics/tb_favourite_inverse.svg":"../pics/tb_favourite.svg"
                                                visible: starred//star
                                                sourceSize.height: platformStyle.graphicSizeTiny
                                                sourceSize.width: platformStyle.graphicSizeTiny
                                            }
                                            Image {
                                                asynchronous: true
                                                source: window.useLightTheme?"../pics/tb_share_inverse.svg":"../pics/tb_share.svg"
                                                visible: shared//share
                                                sourceSize.height: platformStyle.graphicSizeTiny
                                                sourceSize.width: platformStyle.graphicSizeTiny
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        //                Text {
                        //                    id: summary
                        //                    width: parent.width
                        //                    wrapMode: Text.WordWrap
                        //                    text: "<span>"+mainContent+"</span>"
                        //                    font.pixelSize: window.fontSizeMedium
                        //                    color: platformStyle.colorNormalLight
                        //                }

                        WebView {
                            id: summary
                            anchors.top: feedTitleRect.bottom
                            //width: feedItemRect.width
                            preferredWidth: feedItemRect.width
                            preferredHeight: feedItemFlickable.height - feedTitleRect.height
                            property string imgCssStr: window.autoResizeImg ? "<style type=\"text/css\">body {background-color: #EEEEEE} img{max-width:"+(feedItemTitleBar.width)+"px;height:auto;}</style>" : "<style type=\"text/css\">body {background-color: #EEEEEE}</style>"
                            property string webcontent : Math.abs(view.currentIndex - index) > 1 ? "" : content
                            html: "<head>"+imgCssStr+"</head><span>"+webcontent+"</span>"
                            pressGrabTime : view.moving ? 30000 : 500

                            settings.minimumFontSize : window.fontSizeMedium
                            settings.pluginsEnabled : false
                            settings.autoLoadImages : window.autoLoadImages
                            renderingEnabled: true
                            //settings.offlineWebApplicationCacheEnabled : true
                            onUrlChanged: { feedItemFlickable.contentX = 0; feedItemFlickable.contentY = 0; }
                        }
                    }

                    ScrollBar {
                        id: vertical
                        flickableItem: feedItemFlickable
                        orientation: Qt.Vertical
                        anchors { right: feedItemFlickable.right; top: feedItemFlickable.top }
                    }

                    ScrollBar {
                        id: horizontal
                        flickableItem: feedItemFlickable
                        orientation: Qt.Horizontal
                        policy: Symbian.ScrollBarWhenNeeded
                        anchors { left: feedItemFlickable.left; bottom: feedItemFlickable.bottom }
                    }
                }
            }
        }
    }
}
