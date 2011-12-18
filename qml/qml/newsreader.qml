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
import com.nokia.extras 1.0

import "../js/OAuthConstants.js" as Const
import "../js/storage.js" as Storage
import "../js/main.js" as Script

Window {
    id: window
    //platformInverted: ( useLightTheme && (pageStack.currentPage != null && pageStack.currentPage.platformInverted == undefined) )
    property bool busyInd: false
    property bool autoResizeImg: true
    property bool showFullHtml: false
    property bool globalUnreadFilter: false
    property bool useLightTheme: false
    property bool useBiggerFonts: false
    property bool autoLoadImages: true
    property bool swipeGestureEnabled: true

    property int fontSizeSmall: useBiggerFonts ? 1.1*platformStyle.fontSizeSmall : platformStyle.fontSizeSmall
    property int fontSizeMedium: useBiggerFonts ? 1.1*platformStyle.fontSizeMedium : platformStyle.fontSizeMedium
    property int fontSizeLarge: useBiggerFonts ? 1.1*platformStyle.fontSizeLarge : platformStyle.fontSizeLarge

    PageStack {
        id: pageStack

        anchors.fill: parent
        toolBar: toolBar

        signal busyStart()
        signal busyStop()
        onBusyStart: Script.busyIndicatorStart()
        onBusyStop: Script.busyIndicatorStop()
    }

    //Event preventer when page transition is active
    MouseArea {
        anchors.fill: parent
        enabled: pageStack.busy
    }

    StatusBar {
        id: statusBar
        anchors.top: window.top

        Row {
            id: topRow
            BusyIndicator {
                id: globalBusy
                visible: (window.busyInd && !centralMessageArea.visible)//false
                running: window.busyInd
                height: statusBar.height
                width: statusBar.height
            }
            ListItemText {
                id: topMsgText
                z: 0
                text: qsTr("gNewsReader")
                font.pixelSize: platformStyle.fontSizeSmall
                width: 0.4*statusBar.width
            }
        }
    }

    InfoBanner {
        id: pageInfoBanner
    }

    Rectangle {
        id: centralMessageArea
        anchors { fill: parent; topMargin: statusBar.height; bottomMargin: toolBar.height }
        color: window.useLightTheme? "#7f7f7f" : platformStyle.colorNormalDark
        visible: !(pageStack.currentPage != null && pageStack.currentPage.mainCompVisible)

        BorderImage {
            source: "../pics/msg_background.svg"
            border { left: 15; top: 15; right: 15; bottom: 15 }
            smooth: true
            asynchronous: true
            anchors.centerIn: msgAreaColumn
            width: msgAreaColumn.width + 30
            height: msgAreaColumn.height + 30
        }
        Column {
            id: msgAreaColumn
            anchors.centerIn: parent
            spacing: platformStyle.paddingMedium

            BusyIndicator {
                id: centralBusy
                visible: window.busyInd
                running: window.busyInd
                anchors.horizontalCenter: parent.horizontalCenter
                height: platformStyle.graphicSizeLarge
                width: platformStyle.graphicSizeLarge
            }
            ListItemText {
                id: infoMessage
                visible: centralMessageArea.visible
                text: qsTr("gNewsReader")
                role: "Title"
                horizontalAlignment: Text.AlignHCenter
            }
        }
    }

    ToolBar {
        id: toolBar
        anchors.bottom: window.bottom
        tools: ToolBarLayout {
            id: toolBarLayout
            ToolButton {
                flat: true
                iconSource: "toolbar-back"
                onClicked: Qt.quit()
            }
        }
    }

    SubscriptionsPage {
        id: subscrListPage
        property string filtermode: Storage.getSettingVal("filtermode", "all")
        property bool isCountDirty: false

        model: ListModel {
            id: subListModel
        }

        onFolderClicked: Script.folderClicked(index, folderId, expanded)
        onItemClicked: Script.loadById(itemId, feedTitle)
        onItemOptions: Script.editSub(listIndex, itemId, menuId, feedTitle)
        onFiltermodeChanged: { if(filtermode!=Storage.getSettingVal("filtermode")) Script.filterSubList(filtermode); Storage.setSetting("filtermode",filtermode) }
        onSearchForFeed: Script.searchForFeed(query)
        onStatusChanged: {
            if(status == PageStatus.Activating) {
                if(subscrListPage.isCountDirty) {
                    subscrListPage.isCountDirty = false; Script.updateSubscriptions()
                }
            }
        }

        anchors { fill: parent; topMargin: statusBar.height; bottomMargin: toolBar.height }

        tools: ToolBarLayout {
            ToolButton {
                enabled: !pageStack.busy
                iconSource: "../pics/tb_close_stop.svg"
                onClicked: Qt.quit()
            }
            ToolButton {
                iconSource: "toolbar-refresh"
                onClicked: Script.refreshSubList("count")
                onPlatformPressAndHold: Script.refreshSubList("full")
            }
            ToolButton {
                iconSource: "toolbar-settings"
                onClicked: pageStack.push(Qt.resolvedUrl("../qml/components/ApplicationSettings.qml"))
            }
            ToolButton {
                iconSource: "toolbar-menu"
                onClicked: subListMenuComp.createObject(subscrListPage).open()
            }
        }

        Component {
            id: subListMenuComp
            Menu {
                id: subListMenu
                onStatusChanged: if(status == DialogStatus.Closed) subscrListPage.takeFocus()
                content: MenuLayout {
                    MenuItem {
                        text: qsTr("Subscribe to New Feed")
                        onClicked: subscrListPage.showSubDialog("","")
                    }
                    MenuItem {
                        text: subscrListPage.filtermode == "unread"? qsTr("Show All") : qsTr("Show Unread")
                        onClicked: subscrListPage.filtermode == "all" ? subscrListPage.filtermode = "unread": subscrListPage.filtermode = "all"
                    }
                    MenuItem {
                        text: qsTr("Load Starred Feeds")
                        onClicked: Script.loadStarred()
                    }
                    MenuItem {
                        text: qsTr("Load New Feeds")
                        onClicked: Script.loadUnreadNews()
                    }
                    MenuItem {
                        text: qsTr("Load All Feeds")
                        onClicked: Script.loadAllNews()
                    }
                    MenuItem {
                        text: qsTr("Clear Authorization Data")
                        onClicked: Script.clearAuthData()
                    }
                }
            }
        }
    }

    FeedListPage {
        id: feedListPage
        model: ListModel {
            id: feedListModel
        }

        signal toggleTagStatus(int index, string feedId, string feedUrl, string tagName, bool currTagVal, string tagAct)
        onToggleTagStatus: Script.toggleTagStatus(tagAct, currTagVal, tagName, feedId, decodeURIComponent(feedUrl), index)
        signal updateFeedCount(string feedUrl, string categories, int count)
        onUpdateFeedCount: Script.updateCount(decodeURIComponent(feedUrl), categories, count)
        signal shareToReadLater(string serviceName, string feedTitle, string articleUrl)
        onShareToReadLater: Script.sendToReadLaterService(serviceName, feedTitle, articleUrl)
        onItemClicked: { Script.loadFeedDetails(itemIndex, true) }
        anchors { fill: parent; topMargin: statusBar.height; bottomMargin: toolBar.height }

        tools: ToolBarLayout {
            ToolButton {
                iconSource: "toolbar-back"
                enabled: !pageStack.busy
                onClicked: {
                    pageStack.replace(subscrListPage)
                }//Qt.quit();
            }
            ToolButton {
                iconSource: "toolbar-refresh"
                onClicked: Script.reloadNewsUrl(feedListPage.feedUrl, feedListPage.feedExclude, false, feedListPage.feedTitle)
            }
			ToolButton {
                iconSource: "toolbar-settings"
                onClicked: pageStack.push(Qt.resolvedUrl("../qml/components/ApplicationSettings.qml"))
            }
            ToolButton {
                iconSource: "toolbar-menu"
                onClicked: feedListMenuComp.createObject(feedListPage).open()//feedListMenu.open();
            }
        }

        Component {
            id: feedListMenuComp
            Menu {
                id: feedListMenu
                onStatusChanged: if(status == DialogStatus.Closed) feedListPage.takeFocus()
                content: MenuLayout {
                    MenuItem {
                        visible: Script.getCount(decodeURIComponent(feedListPage.feedUrl)) > 0
                        text: qsTr("Mark All as Read")
                        onClicked: subscrListPage.itemOptions(decodeURIComponent(feedListPage.feedUrl), -1, "markAll", feedListPage.feedTitle)
                    }
                    MenuItem {
                        visible: feedListPage.continueId != "ALLLOADED"
                        text: qsTr("Load More Items..")
                        onClicked: Script.loadMore(feedListPage.feedUrl, feedListPage.feedExclude, feedListPage.continueId)
                    }
                    MenuItem {
                        text: feedListPage.filterActive? qsTr("Show All Items") : qsTr("Show Unread Items")
                        onClicked: {
                            if(feedListPage.feedExclude == "user/-/state/com.google/read") feedListPage.feedExclude = ""
                            else feedListPage.feedExclude = "user/-/state/com.google/read"
                            Script.reloadNewsUrl(feedListPage.feedUrl, feedListPage.feedExclude, false, feedListPage.feedTitle)
                        }
                    }
                }
            }
        }
    }

    FeedItemPage {
        id: feedItemPage
        anchors { fill: parent; topMargin: statusBar.height; bottomMargin: toolBar.height }

        onBackToList: { feedListPage.listViewIndex = feedItemPage.index; pageStack.replace(feedListPage) }
        onMarkFeedAsRead: Script.markAsRead(feedindex, replacePage)
        onSaveTags: Script.saveTags(tagsToSave, originalTags, feedItemPage.feedId, feedItemPage.feedUrl)
        onCallSentToReadLater : Script.invokeReadItLaterAddService(inSvc, inUser, inPwd, inTitle, inUrl)
        onSaveAuthData: Script.saveReadForLaterAuth(service, inUser, inPwd)

        signal shareArticle(string shareServiceUrl, string topStatusText)
        onShareArticle: {
            feedItemPage.startIndex = feedItemPage.index;
            pageStack.push(googleAuthPage); topMsgText.text = topStatusText
            googleAuthPage.urlString = shareServiceUrl
        }

        tools: ToolBarLayout {
            ToolButton {
                enabled: !pageStack.busy
                iconSource: "toolbar-back"
                onClicked: feedItemPage.backToList()
            }
            ToolButton {
                enabled: feedItemPage.index > 0
                iconSource: "toolbar-previous"
                flat: false
                onClicked: feedItemPage.loadPrev()
            }
            ToolButton {
                enabled: feedItemPage.index < feedListModel.count - 1
                iconSource: "toolbar-next"
                flat:  false
                onClicked: feedItemPage.loadNext()
            }
            ToolButton {
                iconSource: "toolbar-settings"
                onClicked: { feedItemPage.startIndex = feedItemPage.index; pageStack.push(Qt.resolvedUrl("../qml/components/ApplicationSettings.qml")) }
            }
            ToolButton {
                iconSource: "toolbar-menu"
                onClicked: feedItemMenuComp.createObject(feedItemPage).open()
            }
        }

        Component {
            id: feedItemMenuComp
            Menu {
                id: feedItemMenu
                onStatusChanged: if(status == DialogStatus.Closed) feedItemPage.takeFocus()
                content: MenuLayout {
                    MenuItem {
                        visible: feedItemPage.getCurrentFeed() != null && feedItemPage.getCurrentFeed().articleUrl != null && feedItemPage.getCurrentFeed().articleUrl != ""
                        text: qsTr("Open in Browser")
                        onClicked: appLauncher.openURLDefault(feedItemPage.getCurrentFeed().articleUrl)
                        ToolButton {
                            //iconSource: "../pics/tb_copy.svg"
                            text: qsTr("Copy URL")
                            width: 0.4*parent.width
                            flat: false
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.right: parent.right
                            anchors.rightMargin: platformStyle.paddingLarge
                            onClicked: {
                                var textForCopy = Qt.createQmlObject('import QtQuick 1.1; TextInput {text: ""; visible:false}', feedItemPage, "forCopy");
                                textForCopy.text = feedItemPage.getCurrentFeed().articleUrl; textForCopy.selectAll(); textForCopy.copy(); textForCopy.destroy();
                                feedItemMenu.close()
                            }
                        }
                    }
                    MenuItem {
                        text: (feedItemPage.getCurrentFeed() != null && feedItemPage.getCurrentFeed().keptUnread) ? qsTr("Undo Keep Unread"): qsTr("Keep Unread")

                        onClicked: {
                            Script.toggleTagStatus(Const.KEEP_UNREAD_ACT, feedItemPage.getCurrentFeed().keptUnread, "keptUnread", feedItemPage.getCurrentFeed().feedId, feedItemPage.getCurrentFeed().feedUrl, feedItemPage.index)
                            Script.toggleTagStatus(Const.READ_ACT, feedItemPage.getCurrentFeed().readstatus, "readstatus", feedItemPage.getCurrentFeed().feedId, feedItemPage.getCurrentFeed().feedUrl, feedItemPage.index)
                            Script.updateCount(feedItemPage.getCurrentFeed().feedUrl, feedItemPage.getCurrentFeed().categories, feedItemPage.getCurrentFeed().keptUnread ? -1 : 1)
                        }
                    }
                    MenuItem {
                        text: qsTr("Share")
                        ButtonRow {
                            //width: 0.7*parent.width
                            exclusive: false
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.right: parent.right
                            anchors.rightMargin: platformStyle.paddingLarge
                            ToolButton {
                                iconSource: "../pics/twitter.svg"
                                onClicked: { feedItemPage.shareArticle(Const.getTwitterShareUrl(feedItemPage.getCurrentFeed().articleUrl, feedItemPage.getCurrentFeed().title), "Share (Twitter)"); feedItemMenu.close() }
                            }
                            ToolButton {
                                iconSource: "../pics/facebook.svg"
                                onClicked: { feedItemPage.shareArticle(Const.getFacebookShareUrl(feedItemPage.getCurrentFeed().articleUrl, feedItemPage.getCurrentFeed().title), "Share (Facebook)"); feedItemMenu.close() }
                            }
                            ToolButton {
                                iconSource: "../pics/read_it_later.svg"
                                onClicked: {
                                    Script.sendToReadLaterService(Const.SERVICE_READ_IT_LATER, feedItemPage.getCurrentFeed().title, feedItemPage.getCurrentFeed().articleUrl)
                                    feedItemMenu.close()
                                }
                            }
                            ToolButton {
                                iconSource: "../pics/instapaper.svg"
                                onClicked: {
                                    Script.sendToReadLaterService(Const.SERVICE_INSTAPAPER, feedItemPage.getCurrentFeed().title, feedItemPage.getCurrentFeed().articleUrl)
                                    feedItemMenu.close()
                                }
                            }
                        }
                    }
                    MenuItem {
                        text: qsTr("Google")
                        ButtonRow {
                            exclusive: false
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.right: parent.right
                            anchors.rightMargin: platformStyle.paddingLarge
                            ToolButton {
                                iconSource: "../pics/tb_favourite.svg"
                                checkable: true
                                checked: feedItemPage.getCurrentFeed() != null && feedItemPage.getCurrentFeed().starred
                                onClicked: { Script.toggleTagStatus(Const.STAR_ACT, feedItemPage.getCurrentFeed().starred, "starred", feedItemPage.getCurrentFeed().feedId, feedItemPage.getCurrentFeed().feedUrl, feedItemPage.index); feedItemMenu.close() }
                            }
                            ToolButton {
                                iconSource: "../pics/tb_tag.svg"
                                onClicked: { feedItemPage.showEditTagDialog(); feedItemMenu.close() }
                            }
                            ToolButton {
                                iconSource: "../pics/googleplus.png"
                                onClicked: { feedItemPage.shareArticle(Const.getGooglePlusShareUrl(feedItemPage.getCurrentFeed().articleUrl, feedItemPage.getCurrentFeed().title), "Share (Google+)"); feedItemMenu.close() }
                            }
                            ToolButton {
                                iconSource: "../pics/tb_like.svg"
                                onClicked: { feedItemPage.shareArticle(Const.getGooglePlusOneUrl(feedItemPage.getCurrentFeed().articleUrl), "+1 (Google+)"); feedItemMenu.close() }
                            }
                        }
                     }
                }
            }
        }
    }

    GoogleOAuth2 {
        id: googleAuthPage
        anchors { fill: parent; topMargin: statusBar.height; bottomMargin: toolBar.height }

        onAuthComplete: Script.oAuthComplete(token, refreshtoken)

        tools: ToolBarLayout {
            ToolButton {
                enabled: !pageStack.busy
                iconSource: pageStack.depth == 1 ? "../pics/tb_close_stop.svg" : "toolbar-back"
                onClicked: pageStack.depth == 1 ? Qt.quit() : pageStack.pop()
            }
            ToolButton {
                iconSource: "../pics/tb_zoom_out.svg"
                onClicked: googleAuthPage.zoomOut()
            }
            ToolButton {
                iconSource: "../pics/tb_zoom_in.svg"
                onClicked: googleAuthPage.zoomIn()
            }
        }
    }

    Component.onCompleted: Script.startApp(true);
}
