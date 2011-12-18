import QtQuick 1.0
import com.nokia.symbian 1.0

Page {
    id: aboutAppPage
    property bool mainCompVisible : true
    property bool platformInverted : false

    anchors { fill: parent; topMargin: statusBar.height; bottomMargin: toolBar.height }
    onStatusChanged: {
        if(status == PageStatus.Active) { topMsgText.text=qsTr("About Application") }
    }

    Loader {
        id: aboutAppLoader
        sourceComponent: aboutAppComponent//undefined
        anchors { fill: parent; margins: platformStyle.paddingLarge }
        focus: true
    }

    Component {
        id:aboutAppComponent
        Flickable {
            width: parent.width
            height: parent.height
            contentWidth: parent.width// - 2*platformStyle.paddingLarge
            contentHeight: mainColumn.height
            boundsBehavior : Flickable.StopAtBounds

            Item {
                id: mainItem
                width: parent.width
                Column {
                    id: mainColumn
                    width: parent.width
                    spacing: platformStyle.paddingMedium
                    Row {
                        spacing: platformStyle.paddingMedium
                        Image {
                            id: gnewsReaderImg
                            source: "../../pics/gNewsReader.svg"
                            sourceSize.height: platformStyle.graphicSizeLarge
                            sourceSize.width: platformStyle.graphicSizeLarge
                        }

                        Column {
                            id: aboutAppHeaderColumn
                            anchors.verticalCenter: gnewsReaderImg.verticalCenter
                            ListItemText {text: qsTr("gNewsReader"); anchors.horizontalCenter: aboutAppHeaderColumn.horizontalCenter }
                            ListItemText { text: qsTr("Version 1.50"); anchors.horizontalCenter: aboutAppHeaderColumn.horizontalCenter; role: "SubTitle"}
                        }
                    }
                    ListItemText {
                        text: qsTr("Open Source Google Reader Client for Symbian^3.<br><br>For Bug Reports, Feedback and Feature Requests <a href=\"https://projects.developer.nokia.com/gNewsReader\">Go to Project Website</a> or e-mail author <a href=\"mailto:yogeshwarp@ovi.com\">yogeshwarp@ovi.com</a><br><br>© 2011 Yogeshwar Padhyegurjar<br>")
                        wrapMode: Text.WordWrap
                        width: parent.width
                        role: "SubTitle"
                        onLinkActivated: { console.log(link); if(link.indexOf("mailto") > -1) Qt.openUrlExternally(link); else appLauncher.openURLDefault(link)}
                    }
                    ListItemText {
                        text: qsTr("Project Team")
                        wrapMode: Text.Wrap
                        width: parent.width
                    }
                    ListItemText {
                        text: "Yogeshwar Padhyegurjar"
                        wrapMode: Text.Wrap
                        width: parent.width
                    }
                    ListItemText {
                        text: qsTr("Author (twitter: @yogeshwarp)")
                        role: "SubTitle"
                        wrapMode: Text.Wrap
                        elide: Text.ElideNone
                        width: parent.width
                    }
                    ListItemText {
                        text: "Saurav Srivastava"
                        wrapMode: Text.Wrap
                        width: parent.width
                    }
                    ListItemText {
                        text: qsTr("UI Feedback & Refinement / Artwork<br>(twitter: @gx_saurav)")
                        role: "SubTitle"
                        wrapMode: Text.Wrap
                        elide: Text.ElideNone
                        width: parent.width
                    }
                    ListItemText {
                        text: qsTr("Translators")
                        wrapMode: Text.Wrap
                        width: parent.width
                    }
                    ListItemText {
                        text: "Paweł Gawlik"
                        wrapMode: Text.Wrap
                        width: parent.width
                    }
                    ListItemText {
                        text: qsTr("Polish Language (twitter: @pagaw102)")
                        role: "SubTitle"
                        wrapMode: Text.Wrap
                        elide: Text.ElideNone
                        width: parent.width
                    }
                    ListItemText {
                        text: "Yeatse"
                        wrapMode: Text.Wrap
                        width: parent.width
                    }
                    ListItemText {
                        text: qsTr("Simplified Chinese (twitter: @yeatse)")
                        role: "SubTitle"
                        wrapMode: Text.Wrap
                        elide: Text.ElideNone
                        width: parent.width
                    }
                    ListItemText {
                        text: "Wei-Lin Chen"
                        wrapMode: Text.Wrap
                        width: parent.width
                    }
                    ListItemText {
                        text: qsTr("Traditional Chinese (twitter: @garykb8)")
                        role: "SubTitle"
                        wrapMode: Text.Wrap
                        elide: Text.ElideNone
                        width: parent.width
                    }
                    ListItemText {
                        text: "kingofcomedy"
                        wrapMode: Text.Wrap
                        width: parent.width
                    }
                    ListItemText {
                        text: qsTr("German Language")
                        role: "SubTitle"
                        wrapMode: Text.Wrap
                        elide: Text.ElideNone
                        width: parent.width
                    }
                    ListItemText {
                        text: "Аспарух Калянджиев"
                        wrapMode: Text.Wrap
                        width: parent.width
                    }
                    ListItemText {
                        text: qsTr("Bulgarian Language (twitter: @acnapyx)")
                        role: "SubTitle"
                        wrapMode: Text.Wrap
                        elide: Text.ElideNone
                        width: parent.width
                    }
                    ListItemText {
                        text: "Ville Makkonen"
                        wrapMode: Text.Wrap
                        width: parent.width
                    }
                    ListItemText {
                        text: qsTr("Finnish Language")
                        role: "SubTitle"
                        wrapMode: Text.Wrap
                        elide: Text.ElideNone
                        width: parent.width
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
