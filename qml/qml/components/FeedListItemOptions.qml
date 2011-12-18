import QtQuick 1.0
import com.nokia.symbian 1.0

ContextMenu {
    id: feedItemOptionsMenu
    property int feedIndex: 0
    property string feedId
    property string feedUrl
    property bool readstatus
    property bool keptUnread
    property bool starred
    property string categories
    property string title
    property string articleUrl

    MenuLayout {
        MenuItem {
            id: menuMarkAsRead
            text: qsTr("Mark as Read")
            //platformLeftMargin: 2 * platformStyle.paddingMedium
            visible: !feedItemOptionsMenu.readstatus
            onClicked: {
                feedListPage.toggleTagStatus(feedItemOptionsMenu.feedIndex, feedItemOptionsMenu.feedId, feedItemOptionsMenu.feedUrl, "readstatus", feedItemOptionsMenu.readstatus, "user/-/state/com.google/read")
                if(feedItemOptionsMenu.keptUnread) feedListPage.toggleTagStatus(feedItemOptionsMenu.feedIndex, feedItemOptionsMenu.feedId, feedItemOptionsMenu.feedUrl, "keptUnread", feedItemOptionsMenu.keptUnread, "user/-/state/com.google/kept-unread")
                feedListPage.updateFeedCount(feedItemOptionsMenu.feedUrl, feedItemOptionsMenu.categories, 1)
            }
        }
        MenuItem {
            //platformLeftMargin: 2 * platformStyle.paddingMedium
            text: qsTr("Keep Unread")
            visible: feedItemOptionsMenu.readstatus && !feedItemOptionsMenu.keptUnread
            onClicked: {
                feedListPage.toggleTagStatus(feedItemOptionsMenu.feedIndex, feedItemOptionsMenu.feedId, feedItemOptionsMenu.feedUrl, "readstatus", feedItemOptionsMenu.readstatus, "user/-/state/com.google/read")
                feedListPage.toggleTagStatus(feedItemOptionsMenu.feedIndex, feedItemOptionsMenu.feedId, feedItemOptionsMenu.feedUrl, "keptUnread", feedItemOptionsMenu.keptUnread, "user/-/state/com.google/kept-unread")
                feedListPage.updateFeedCount(feedItemOptionsMenu.feedUrl, feedItemOptionsMenu.categories, -1)
            }
        }
        MenuItem {
            text: feedItemOptionsMenu.starred ? qsTr("Remove Star") : qsTr("Add Star")
            //platformLeftMargin: 2 * platformStyle.paddingMedium
            onClicked: feedListPage.toggleTagStatus(feedItemOptionsMenu.feedIndex, feedItemOptionsMenu.feedId, feedItemOptionsMenu.feedUrl, "starred", feedItemOptionsMenu.starred, "user/-/state/com.google/starred")
        }
        MenuItem {
            //platformLeftMargin: 2 * platformStyle.paddingMedium
            text: qsTr("Send To")
            ButtonRow {
                    width: 0.5*parent.width
                    exclusive: false
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: parent.right
                    anchors.rightMargin: platformStyle.paddingLarge
                    ToolButton {
                            iconSource: "../../pics/read_it_later.svg"
                            onClicked: { feedListPage.shareToReadLater("READ_IT_LATER", feedItemOptionsMenu.title, feedItemOptionsMenu.articleUrl); feedItemOptionsMenu.close() }
                    }
                    ToolButton {
                            iconSource: "../../pics/instapaper.svg"
                            onClicked: { feedListPage.shareToReadLater("INSTAPAPER", feedItemOptionsMenu.title, feedItemOptionsMenu.articleUrl); feedItemOptionsMenu.close() }
                    }
            }
        }
    }
}
