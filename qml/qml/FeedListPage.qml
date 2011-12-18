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

import "../js/OAuthConstants.js" as Const

Page {
    id: feedListPage
    property ListModel model
    property string continueId: ""
    property string feedUrl: ""
    property string feedExclude: ""
    property string feedTitle: ""
    property int listViewIndex:0

    property bool filterActive: feedListPage.feedExclude == "user/-/state/com.google/read"
    property bool mainCompVisible : (feedListPage.model != null && feedListPage.model.count > 0)

    signal itemClicked( string itemIndex )
    signal takeToTop()
    signal takeFocus()

    onTakeToTop: if(feedListLoader.item != null) feedListLoader.item.takeToTop()
    onTakeFocus: if(feedListLoader.item != null) feedListLoader.item.takeFocus()
    onStatusChanged: {
        if(status == PageStatus.Activating) {if (feedListLoader.sourceComponent == undefined) feedListLoader.sourceComponent = feedListComponent}
        if(status == PageStatus.Active) topMsgText.text = (filterActive? "!" : "")+feedListPage.feedTitle
        if(status == PageStatus.Inactive) feedListLoader.sourceComponent = undefined
    }

    Loader {
        id: feedListLoader
        sourceComponent: undefined
        anchors { fill: parent; margins: 0 }
        focus: true
    }

//    Component {
//        id: feedlistHeader

//        Item {
//            width: screen.width
//            height:  0
//            Image {
//                anchors.bottom: parent.top
//                anchors.horizontalCenter: parent.horizontalCenter
//                anchors.bottomMargin: 10
//                source:  "../pics/tb_reload.svg"
//                opacity: -feedListView.contentY > 120 ? 1 : 0;
//                Behavior on opacity { NumberAnimation { duration: 100  } }
//                rotation: {
//                    var newAngle = - feedListView.contentY;
//                    if (newAngle > 180) {
//                        feedListReloadtimer.start();
//                        return -180;
//                    } else {
//                        newAngle = newAngle > 180 ? 180 : 0;
//                        return -newAngle;
//                    }
//                }
//                Behavior on rotation { NumberAnimation { duration: 150 } }
//            }
//        }
//    }

    Component {
        id:feedListComponent
        Rectangle {
            signal takeToTop()
            signal takeFocus()
            color: window.useLightTheme ? "#f2f2f2" : platformStyle.colorNormalDark
            onTakeFocus: feedListView.forceActiveFocus()
            onTakeToTop: feedListView.positionViewAtIndex(0, ListView.Beginning)
            focus: true

            ListView {
                id: feedListView
                focus: true
                delegate: feedDelegate
                anchors { fill: parent; margins: 0 }
                model: feedListPage.model
                highlightFollowsCurrentItem: true
//                header: feedListHeader
//                footer: feedListFooter
                //onContentYChanged: console.log(contentY + ":" + contentItem.y)

//                Component {
//                    id: feedListHeader
//                    PullToActivate {
//                        myListView: feedListView
//                    }
//                }

//                Component {
//                    id: feedListFooter
//                    PullToActivate {
//                        myListView: feedListView
//                        isHeader : false
//                    }
//                }
            }

//            ScrollBar {
//                id: vertical
//                flickableItem: feedListView
//                orientation: Qt.Vertical
//                anchors { right: feedListView.right; top: feedListView.top }
//            }
            ScrollDecorator {
                id: scrolldecorator
                flickableItem: feedListView
            }
            Component.onCompleted: { feedListView.forceActiveFocus(); if(feedListPage.listViewIndex != 0) { feedListView.positionViewAtIndex(feedListPage.listViewIndex, ListView.Center); feedListView.currentIndex = feedListPage.listViewIndex; feedListPage.listViewIndex = 0 } }
        }
    }

    Component {
        id: feedDelegate

        ListItem {
            id: newsfeedItem
            width: feedListView.width
            implicitHeight: feedItemColumn.height + 2*platformStyle.paddingMedium
            //platformInverted: window.useLightTheme

            BorderImage {
                visible: !readstatus && newsfeedItem.mode == "normal"
                source: window.useLightTheme?"../pics/list_default_feed_inverse.svg":"../pics/list_default_feed.svg"
                //border { left: 0; top: 0; right: 0; bottom: 0 }
                smooth: false
                anchors.fill: parent
            }

            Column {
                id: feedItemColumn
                spacing: platformStyle.paddingMedium
                anchors {
                    top: newsfeedItem.top
                    left: newsfeedItem.left
                    margins: platformStyle.paddingMedium
                }
                width: newsfeedItem.width - 2*platformStyle.paddingMedium

                ListItemTextG {
                    id: newsFeedTitle
                    //mode: newsfeedItem.mode
                    platformInverted: window.useLightTheme
                    text: title
                    width: parent.width
                    //maximumLineCount: 3
                    elide: Text.ElideNone
                    font.pixelSize: window.fontSizeLarge
                    wrapMode: Text.WordWrap

                    property color colorMid: window.useLightTheme ? "#666666"
                                                                   : platformStyle.colorNormalMid
                    property color colorLight: window.useLightTheme ? "#282828"
                                                                     : platformStyle.colorNormalLight

                    color: readstatus ? colorMid : colorLight
//                        onModeChanged: color = (readstatus ? (window.useLightTheme ? platformStyle.colorNormalMidInverted
//                                                                              : platformStyle.colorNormalMid) : color)
                }

                Row {
                    width: parent.width
                    ListItemTextG {
                        id: newsFeedSrc
                        mode: newsfeedItem.mode
                        role: "SubTitle"
                        text: source
                        platformInverted: window.useLightTheme
                        width: parent.width - itemStatusBar.width
                        font.pixelSize: window.fontSizeMedium
                    }

                    Row {
                        id: itemStatusBar
                        anchors.bottom: newsFeedSrc.bottom
                        ListItemTextG {
                            id: newsFeedTime
                            mode: newsfeedItem.mode
                            role: "SubTitle"
                            platformInverted: window.useLightTheme
                            text: Const.humaneDate(feedTime*1)
                            font.pixelSize: window.fontSizeMedium
                        }
                        Image {
                            asynchronous: true
                            source: window.useLightTheme?"../pics/tb_favourite_inverse.svg":"../pics/tb_favourite.svg"
                            visible: starred
                            sourceSize.height: platformStyle.graphicSizeTiny
                            sourceSize.width: platformStyle.graphicSizeTiny
                        }
                        Image {
                            asynchronous: true
                            source: window.useLightTheme?"../pics/tb_share_inverse.svg":"../pics/tb_share.svg"
                            visible: shared
                            sourceSize.height: platformStyle.graphicSizeTiny
                            sourceSize.width: platformStyle.graphicSizeTiny
                        }
                    }
                }
            }

            onClicked: feedListPage.itemClicked(index)
            onPressAndHold: {
                var optionMenu = Qt.createComponent("components/FeedListItemOptions.qml").createObject(feedListPage)
                optionMenu.feedIndex = index; optionMenu.feedId = feedId; optionMenu.feedUrl = feedListPage.feedUrl; optionMenu.starred = starred; optionMenu.readstatus = readstatus; optionMenu.keptUnread = keptUnread; optionMenu.categories = categories
                optionMenu.title = title; optionMenu.articleUrl = articleUrl
                optionMenu.open()
            }
        }
    }
}
