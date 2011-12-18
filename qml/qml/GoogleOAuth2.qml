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
//import Qt.labs.gestures 1.0

import "../js/OAuthConstants.js" as Const
import "../js/storage.js" as Storage
import "../js/googleOAuth.js" as OAuth

Page {
    id: googleAuthPage

    property string token: ""
    property string urlString : ""
    property bool mainCompVisible : true

    signal authComplete(string token, string refreshtoken)
    signal zoomIn()
    signal zoomOut()
    onZoomIn: webViewLoader.item.zoomIn()
    onZoomOut: webViewLoader.item.zoomOut()
    //visible: false

    Loader {
        id: webViewLoader
        opacity: 1
        sourceComponent: undefined//googleAuthWebView
        anchors { fill: parent; margins: 0 }
    }

    onStatusChanged: {
        if(status == PageStatus.Activating) { if(webViewLoader.sourceComponent == undefined) webViewLoader.sourceComponent = googleAuthWebView }
        if(status == PageStatus.Deactivating) googleAuthPage.urlString = ""
        if(status == PageStatus.Inactive) webViewLoader.sourceComponent = undefined
    }

    Component {
        id:googleAuthWebView

        Rectangle {
            id: webPageRect
            color: "#FFFFFF"
            signal zoomIn()
            signal zoomOut()
            onZoomIn: loginView.contentsScale += 0.1
            onZoomOut: loginView.contentsScale -= 0.1

            Flickable {
                id:flickableLogin
                width: parent.width
                height: parent.height
                contentWidth: loginView.width
                contentHeight: loginView.height
                boundsBehavior : Flickable.StopAtBounds
                pressDelay: 200

                WebView {
                    id: loginView
                    newWindowComponent: newWindowDialog
                    newWindowParent: googleAuthPage

                    preferredHeight: webPageRect.height
                    preferredWidth: webPageRect.width

                    settings.minimumFontSize : platformStyle.fontSizeMedium
                    settings.defaultFontSize: platformStyle.fontSizeMedium
                    settings.defaultFixedFontSize: platformStyle.fontSizeMedium
                    settings.minimumLogicalFontSize: platformStyle.fontSizeMedium

                    settings.pluginsEnabled : true
                    settings.offlineWebApplicationCacheEnabled : true
                    settings.javascriptEnabled: true

                    contentsScale: 1.0

                    url: googleAuthPage.urlString

                    onUrlChanged: {
                        //console.log("URL changed:"+url)
                        flickableLogin.contentX  = 0;
                        flickableLogin.contentY  = 0;
                    }

                    onLoadStarted: { pageStack.busyStart(); if(title != null && title != "") topMsgText.text = title }

                    onLoadFinished: {
                        //loginView.evaluateJavaScript("document.bgColor = '#FFFFFF';");
                        topMsgText.text = title
                        OAuth.loadComplete(title, url)
                        pageStack.busyStop()
                    }

                    onLoadFailed: {
                        console.log("OOPS! something went really wrong:"+url);
                        pageStack.busyStop()
                    }

//                    GestureArea {
//                        anchors.fill: parent

//                        function calcZoomDelta(zoom, percent) {
//                           var newzoom = zoom + Math.log(percent)/Math.log(2)
//                            return newzoom < 1? Math.max(1, newzoom): Math.min(2.5, newzoom)
//                        }
//                        onPinch: {
//                            parent.contentsScale = calcZoomDelta(parent.contentsScale, gesture.scaleFactor)
//                        }
//                    }

                }
            }

//            PinchArea {
//                enabled: true
//                pinch.target: flickableLogin
//                pinch.minimumScale: 1.0
//                pinch.maximumScale: 2.25
//            }

            ScrollBar {
                id: vertical
                flickableItem: flickableLogin
                orientation: Qt.Vertical
                anchors { right: flickableLogin.right; top: flickableLogin.top }
            }

            ScrollBar {
                id: horizontal
                flickableItem: flickableLogin
                orientation: Qt.Horizontal
                anchors { left: flickableLogin.left; bottom: flickableLogin.bottom }
            }
        }
    }

    Component {
        id: newWindowDialog
        Rectangle {
            id: newWebPageRect
            width: feedItemPage.width*0.95
            height: dialogColumn.height + 2*platformStyle.paddingMedium
            anchors.centerIn: parent
            color: platformStyle.colorNormalDark//"#000000"

            Column {
                id: dialogColumn
                width: parent.width
                spacing: platformStyle.paddingMedium

                anchors {
                    left: newWebPageRect.left
                    top: newWebPageRect.top
                    margins: platformStyle.paddingMedium
                }

                ListItemText {
                    text: qsTr("Opening Links that Lauch new Window is currently not supported. If you are trying to Recover/Create New Google Account please use Web Browser on your Device")
                    role: "Title"
                    width: newWebPageRect.width - 2*platformStyle.paddingMedium
                    wrapMode: Text.WordWrap
                    elide: Text.ElideNone
                    horizontalAlignment: Text.AlignHCenter
                }

                ButtonRow {
                    width:newWebPageRect.width - 2*platformStyle.paddingMedium
                    Button {
                        text: qsTr("Close")
                        onClicked:  { newWebPageRect.visible = false/*; embBrowser.url = ""*/}
                    }
                }

                WebView {
                    id: embBrowser
                    visible: false
                }
            }
        }
    }
}

