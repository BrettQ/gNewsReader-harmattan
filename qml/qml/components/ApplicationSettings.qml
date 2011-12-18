import QtQuick 1.0
import com.nokia.symbian 1.0
import "../../js/storage.js" as Storage

Page {
    id: appSettingsPage
    property bool mainCompVisible : true
    property bool platformInverted : false

    anchors { fill: parent; topMargin: statusBar.height; bottomMargin: toolBar.height }
    onStatusChanged: if(status == PageStatus.Active) { topMsgText.text=qsTr("Settings") }

    Loader {
        id: appSettingsLoader
        sourceComponent: appSettingsComponent//undefined
        anchors { fill: parent; margins: 0 }
        focus: true
    }

    Component {
        id:appSettingsComponent
        Flickable {
            width: parent.width
            height: parent.height
            contentWidth: parent.width
            contentHeight: mainColumnSettings.height
            boundsBehavior : Flickable.StopAtBounds
            Item {
                id: appSettingsItem
                width: parent.width
                Column {
                    id: mainColumnSettings
                    width: parent.width
                    ListItem {
                        ListItemText {text: qsTr("About gNewsReader"); anchors.centerIn: parent}
                        onClicked: { pageStack.push(Qt.resolvedUrl("AboutApplicationPage.qml")) }
                        width: parent.width
                    }
                    MenuItem {
                        text: qsTr("Use Light Theme")
                        Switch {
                            id: lightThemeSwitch
                            checked: window.useLightTheme
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.right: parent.right
                            anchors.rightMargin: platformStyle.paddingLarge
                            onCheckedChanged:  {
                                Storage.setSetting('useLightTheme', checked)
                                window.useLightTheme = checked
                            }
                        }
                        width: parent.width
                        onClicked: lightThemeSwitch.checked = !lightThemeSwitch.checked//lightThemeSwitch.clicked()
                    }
                    MenuItem {
                        text: qsTr("Unread Filter Global")
                        Switch {
                            id: unreadFilterGolbalSwitch
                            checked: window.globalUnreadFilter
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.right: parent.right
                            anchors.rightMargin: platformStyle.paddingLarge
                            onCheckedChanged:  {
                                Storage.setSetting('globalUnreadFilter', checked)
                                window.globalUnreadFilter = checked
                            }
                        }
                        width: parent.width
                        onClicked: unreadFilterGolbalSwitch.checked = !unreadFilterGolbalSwitch.checked//unreadFilterGolbalSwitch.clicked()
                    }
                    MenuItem {
                        text: qsTr("Auto Image Resize")
                        Switch {
                            id: autoResizeImageSwitch
                            checked: window.autoResizeImg
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.right: parent.right
                            anchors.rightMargin: platformStyle.paddingLarge
                            onCheckedChanged:  {
                                Storage.setSetting('autoResizeImg', checked)
                                window.autoResizeImg = checked
                            }
                        }
                        width: parent.width
                        onClicked: autoResizeImageSwitch.checked = !autoResizeImageSwitch.checked//.clicked()
                    }
                    MenuItem {
                        text: qsTr("Full HTML Content")
                        Switch {
                            id: showFullHtmlSwitch
                            checked: window.showFullHtml
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.right: parent.right
                            anchors.rightMargin: platformStyle.paddingLarge
                            onCheckedChanged:  {
                                Storage.setSetting('showFullHtml', checked)
                                window.showFullHtml = checked
                            }
                        }
                        width: parent.width
                        onClicked: showFullHtmlSwitch.checked = !showFullHtmlSwitch.checked
                    }
                    MenuItem {
                        text: qsTr("Use Bigger Fonts")
                        Switch {
                            id: useBiggerFontsSwitch
                            checked: window.useBiggerFonts
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.right: parent.right
                            anchors.rightMargin: platformStyle.paddingLarge
                            onCheckedChanged:  {
                                Storage.setSetting('useBiggerFonts', checked)
                                window.useBiggerFonts = checked
                            }
                        }
                        width: parent.width
                        onClicked: useBiggerFontsSwitch.checked = !useBiggerFontsSwitch.checked
                    }
                    MenuItem {
                        text: qsTr("Auto Load Images")
                        Switch {
                            id: autoLoadImagesSwitch
                            checked: window.autoLoadImages
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.right: parent.right
                            anchors.rightMargin: platformStyle.paddingLarge
                            onCheckedChanged:  {
                                Storage.setSetting('autoLoadImages', checked)
                                window.autoLoadImages = checked
                            }
                        }
                        width: parent.width
                        onClicked: autoLoadImagesSwitch.checked = !autoLoadImagesSwitch.checked
                    }
                    MenuItem {
                        text: qsTr("Enable Swipe Gesture")
                        Switch {
                            id: swipeEnableSwitch
                            checked: window.swipeGestureEnabled
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.right: parent.right
                            anchors.rightMargin: platformStyle.paddingLarge
                            onCheckedChanged:  {
                                Storage.setSetting('swipeGestureEnabled', checked)
                                window.swipeGestureEnabled = checked
                            }
                        }
                        width: parent.width
                        onClicked: swipeEnableSwitch.checked = !swipeEnableSwitch.checked
                    }
                    MenuItem {
                        text: qsTr("Export OPML file (Requires Google Login)")
                        width: parent.width
                        onClicked: appLauncher.openURLDefault("http://www.google.com/reader/subscriptions/export?hl=en")
                    }
                }
            }
        }
    }

    tools: ToolBarLayout {
        ToolButton {
            //enabled: !pageStack.busy
            iconSource: "toolbar-back"
            onClicked: pageStack.depth == 1 ? Qt.quit() : pageStack.pop()
        }
    }
}
