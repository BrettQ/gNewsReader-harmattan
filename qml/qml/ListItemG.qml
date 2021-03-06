import QtQuick 1.0
import com.nokia.symbian 1.0
//import "." 1.1

Item {
    id: root
    property string mode: "normal" // Read-only
    property alias paddingItem: paddingItem // Read-only

    property bool enabled: true
    property bool subItemIndicator: false
    property bool platformInverted: false

    signal clicked
    signal pressAndHold

//    implicitWidth: ListView.view ? ListView.view.width : screen.width
//    implicitHeight: platformStyle.graphicSizeLarge

    Item {
        id: background
        anchors.fill: parent

        Rectangle {
            height: 1
            color: root.platformInverted ? "#d2d2d2"
                                         : platformStyle.colorDisabledMid
            anchors {
                bottom: parent.bottom
                left: parent.left
                right: parent.right
            }
        }
        Loader {
            id: faderLoader
            opacity: 0
            anchors.fill: background
            sourceComponent: root.mode != "normal" && root.mode != "pressed" ? fader : undefined
        }

        BorderImage {
            id: highlight
            border {
                left: platformStyle.borderSizeMedium
                top: platformStyle.borderSizeMedium
                right: platformStyle.borderSizeMedium
                bottom: platformStyle.borderSizeMedium
            }
            opacity: 0
            anchors.fill: background
        }
    }

    Component {
        id: fader

        BorderImage {
            source: root.platformInverted ? "../pics/qtg_fr_list_"+mode+"_inverse.svg" : privateStyle.imagePath("qtg_fr_list_" + mode)
            border {
                left: platformStyle.borderSizeMedium
                top: platformStyle.borderSizeMedium
                right: platformStyle.borderSizeMedium
                bottom: platformStyle.borderSizeMedium
            }
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        enabled: root.enabled
        onPressed: {
            symbian.listInteractionMode = Symbian.TouchInteraction
            internal.state = "Pressed"
        }
        onClicked: {
            internal.state = ""
            root.clicked()
        }
        onCanceled: {
            internal.state = "Canceled"
        }
        onPressAndHold: {
            internal.state = "PressAndHold"
        }
        onReleased: {
            internal.state = ""
        }
        onExited: {
            internal.state = ""
        }
    }

//    Loader {
//        id: iconLoader
//        sourceComponent: root.subItemIndicator ? subItemIcon : undefined
//        anchors {
//            right: parent.right
//            rightMargin: privateStyle.scrollBarThickness
//            verticalCenter: parent.verticalCenter
//        }
//    }

//    Component {
//        id: subItemIcon

//        Image {
//            source: privateStyle.imagePath(
//                root.enabled ? "qtg_graf_drill_down_indicator"
//                             : "qtg_graf_drill_down_indicator_disabled",
//                root.platformInverted)
//            mirror: LayoutMirroring.enabled
//            sourceSize.width: platformStyle.graphicSizeSmall
//            sourceSize.height: platformStyle.graphicSizeSmall
//        }
//    }

    Keys.onReleased: {
        if (!event.isAutoRepeat && root.enabled && ListView.view) {
            if (event.key == Qt.Key_Select || event.key == Qt.Key_Return || event.key == Qt.Key_Enter) {
                event.accepted = true
                internal.state = "Focused"
            }
        }
    }

    Keys.onPressed: {
        if (!event.isAutoRepeat) {
            switch (event.key) {

            case Qt.Key_Select:
            case Qt.Key_Enter:
            case Qt.Key_Return:
                if (ListView.view && symbian.listInteractionMode != Symbian.KeyNavigation)
                    symbian.listInteractionMode = Symbian.KeyNavigation
                else
                    if (root.enabled) {
                        highlight.source = root.platformInverted ? "../pics/qtg_fr_list_pressed_inverse.svg" : privateStyle.imagePath("qtg_fr_list_pressed")
                        highlight.opacity = 1
                        releasedEffect.restart()
                        root.clicked()
                    }
                event.accepted = true
                break

            case Qt.Key_Up:
                if (ListView.view) {
                    if (symbian.listInteractionMode != Symbian.KeyNavigation) {
                        symbian.listInteractionMode = Symbian.KeyNavigation
                        internal.state = "Focused"
                        ListView.view.positionViewAtIndex(index, ListView.Beginning)
                    } else
                        ListView.view.decrementCurrentIndex()
                    event.accepted = true
                    //symbian.privateListItemKeyNavigation(ListView.view)
                }
                break

            case Qt.Key_Down:
                if (ListView.view) {
                    if (symbian.listInteractionMode != Symbian.KeyNavigation) {
                        symbian.listInteractionMode = Symbian.KeyNavigation
                        ListView.view.positionViewAtIndex(index, ListView.Beginning)
                        internal.state = "Focused"
                    } else
                        ListView.view.incrementCurrentIndex()
                    event.accepted = true
                    //symbian.privateListItemKeyNavigation(ListView.view)
                }
                break

            default:
                event.accepted = false
                break

            }
        }
    }

    ListView.onRemove: SequentialAnimation {
        PropertyAction { target: root; property: "ListView.delayRemove"; value: true }
        ParallelAnimation {
            SequentialAnimation {
                PauseAnimation { duration: 50 }
                NumberAnimation {
                    target: root
                    property: "height"
                    to: 0
                    duration: 150
                    easing.type: Easing.OutQuad
                }
            }
            NumberAnimation {
                target: root
                property: "opacity"
                from: 1
                to: 0
                duration: 100
                easing.type: Easing.Linear
            }
        }
        PropertyAction { target: root; property: "ListView.delayRemove"; value: false }
    }

    ListView.onAdd: SequentialAnimation {
        PropertyAction { target: root; property: "height"; value: 0 }
        ParallelAnimation {
            NumberAnimation {
                target: root
                property: "height"
                to: root.height
                duration: 150
                easing.type: Easing.OutQuad
            }
            NumberAnimation {
                target: root
                property: "opacity"
                from: 0
                to: 1
                duration: 150
                easing.type: Easing.Linear
            }
        }
    }

    SequentialAnimation {
        id: releasedEffect
        PropertyAnimation {
            target: highlight
            property: "opacity"
            to: 0
            easing.type: Easing.Linear
            duration: 150
        }
    }

    Item {
        // non-visible item to create a padding boundary that content items can bind to
        id: paddingItem
        anchors {
            fill: parent
            leftMargin: platformStyle.paddingLarge
            rightMargin: /*iconLoader.status == Loader.Ready ?
                    privateStyle.scrollBarThickness + iconLoader.width + platformStyle.paddingMedium :*/
                    privateStyle.scrollBarThickness
            topMargin: platformStyle.paddingLarge
            bottomMargin: platformStyle.paddingLarge
        }
    }

    StateGroup {
        id: internal

        function getMode() {
            if (internal.state == "Pressed" || internal.state == "PressAndHold")
                return "pressed"
            else if (internal.state == "Focused")
                return "highlighted"
            else if (internal.state == "Disabled")
                return "disabled"
            else
                return "normal"
        }

        // Performance optimization:
        // Use value assignment when property changes instead of binding to js function
        onStateChanged: { root.mode = internal.getMode() }

        function press() {
            //privateStyle.play(Symbian.BasicItem)
            highlight.source = root.platformInverted ? "../pics/qtg_fr_list_pressed_inverse.svg" : privateStyle.imagePath("qtg_fr_list_pressed")
            highlight.opacity = 1
            if (root.ListView.view)
                root.ListView.view.currentIndex = index
        }

        function release() {
//            if (symbian.listInteractionMode != Symbian.KeyNavigation)
//                privateStyle.play(Symbian.BasicItem)
            releasedEffect.restart()
        }

        function releaseHold() {
            releasedEffect.restart()
        }

        function hold() {
            root.pressAndHold()
        }

        function disable() {
            faderLoader.opacity = 1
        }

        function focus() {
            faderLoader.opacity = 1
        }

        function canceled() {
            releasedEffect.restart()
        }

        states: [
            State { name: "Pressed" },
            State { name: "PressAndHold" },
            State { name: "Disabled"; when: !root.enabled },
            State { name: "Focused"; when: (root.ListView.isCurrentItem &&
                symbian.listInteractionMode == Symbian.KeyNavigation) },
            State { name: "Canceled" },
            State { name: "" }
        ]

        transitions: [
            Transition {
                to: "Pressed"
                ScriptAction { script: internal.press() }
            },
            Transition {
                from: "Pressed"
                to: "PressAndHold"
                ScriptAction { script: internal.hold() }
            },
            Transition {
                from: "PressAndHold"
                to: ""
                ScriptAction { script: internal.releaseHold() }
            },
            Transition {
                to: ""
                ScriptAction { script: internal.release() }
            },
            Transition {
                to: "Disabled"
                ScriptAction { script: internal.disable() }
            },
            Transition {
                to: "Focused"
                ScriptAction { script: internal.focus() }
            },
            Transition {
                to: "Canceled"
                ScriptAction { script: internal.canceled() }
            }
        ]
    }
}
