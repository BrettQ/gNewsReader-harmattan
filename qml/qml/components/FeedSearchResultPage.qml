import QtQuick 1.0
import com.nokia.symbian 1.0
import "../" 1.0

Page {
    id: feedSearchResultPage
    property ListModel model
    property bool mainCompVisible : true

    signal subscribeToFeed(string feedid)
    signal addToList(string title, string snippet, string url)
    signal clearResults()

    anchors { fill: parent; topMargin: statusBar.height; bottomMargin: toolBar.height }

    onAddToList: { searchResultListModel.append({"searchtitle": title, "searchsnippet":snippet, "searchurl": url}) }
    onClearResults: searchResultListModel.clear()
    onStatusChanged: if(status == PageStatus.Active) { topMsgText.text=qsTr("Search Results") }

    model: ListModel {
            id: searchResultListModel
        }

    Loader {
        id: feedSearchResultLoader
        sourceComponent: feedResultListComponent//undefined
        anchors { fill: parent; margins: 0 }
        focus: true
    }

    Component {
        id:feedResultListComponent
        Rectangle {
            color: window.useLightTheme? "#f1f1f1" : platformStyle.colorNormalDark
            ListView {
                id: feedResultListView
                focus: true
                delegate: feedResultDelegate
                anchors { fill: parent; margins: 0 }
                model: feedSearchResultPage.model
            }
            ScrollDecorator {
                flickableItem: feedResultListView
            }
            Component.onCompleted: { feedResultListView.forceActiveFocus() }
        }
    }

    Component {
        id: feedResultDelegate

        ListItemG {
            id: feedResultItem
            width: feedResultListView.width
            platformInverted: window.useLightTheme
            height: feedResultItemColumn.height + 2*platformStyle.paddingMedium

            Column {
                id: feedResultItemColumn
                spacing: platformStyle.paddingMedium
                anchors {
                    top: feedResultItem.top
                    left: feedResultItem.left
                    margins: platformStyle.paddingMedium
                }
                width: feedResultItem.width - 2*platformStyle.paddingMedium

                ListItemTextG {
                    id: searchResultTitle
                    text: searchtitle
                    width: parent.width
                    mode: feedResultItem.mode
                    role: "Title"
                    platformInverted: feedResultItem.platformInverted
                    wrapMode: Text.Wrap
                    elide: Text.ElideNone
                }
                ListItemTextG {
                    id: searchResultSnippet
                    text: searchsnippet
                    mode: feedResultItem.mode
                    role: "SubTitle"
                    platformInverted: feedResultItem.platformInverted
                    wrapMode: Text.Wrap
                    elide: Text.ElideNone
                    width: parent.width
                }
                ListItemTextG {
                    id: searchResultUrl
                    text: searchurl
                    mode: feedResultItem.mode
                    role: "SubTitle"
                    platformInverted: feedResultItem.platformInverted
                    width: parent.width
                    wrapMode: Text.Wrap
                    elide: Text.ElideNone
                }
                Button {
                    text: qsTr("Subscribe")
                    onClicked: {
                        subscrListPage.itemOptions("feed/"+searchurl, -1, "subscribe", "")
                        subscrListPage.isCountDirty = true
                    }
                }
            }
        }
    }

    tools: ToolBarLayout {
        ToolButton {
            iconSource: "toolbar-back"
            onClicked: pageStack.depth == 1 ? Qt.quit() : pageStack.pop()
        }

        ToolButton {
            iconSource: "../../pics/tb_about_app.svg"
            onClicked: {pageStack.push(Qt.resolvedUrl("AboutApplicationPage.qml"))}
        }
    }
}
