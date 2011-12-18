import QtQuick 1.0

Text {
    id: root
    property string mode: "normal"
    property string role: "Title"
    property bool platformInverted: false

    // Also role "Heading" taken into account although not explicitely used in evaluations below
    font {
        family: platformStyle.fontFamilyRegular
        pixelSize: (role == "Title" || role == "SelectionSubTitle") ? platformStyle.fontSizeLarge : platformStyle.fontSizeSmall
        weight: (role == "SubTitle" || role == "SelectionTitle") ? Font.Light : Font.Normal
    }
    color: internal.normalColor
    elide: Text.ElideRight
    horizontalAlignment: root.role != "Heading" ? Text.AlignLeft : Text.AlignRight

    // Performance optimization:
    // Use value assignment when property changes instead of binding to js function
    onModeChanged: { color = internal.getColor() }

    QtObject {
        id: internal

        // Performance optmization:
        // Use tertiary operations even though it doesn't look that good
        property color colorMid: root.platformInverted ? "#666666"
                                                       : platformStyle.colorNormalMid
        property color colorLight: root.platformInverted ? "#282828"
                                                         : platformStyle.colorNormalLight
        property color normalColor: (root.role == "SelectionTitle" || root.role == "SubTitle")
                                    ? colorMid : colorLight

        function getColor() {
            if (root.mode == "pressed")
                return root.platformInverted ? "#282828"
                                             : platformStyle.colorPressed
            else if (root.mode == "highlighted")
                return root.platformInverted ? "#282828"
                                             : platformStyle.colorHighlighted
            else if (root.mode == "disabled")
                return root.platformInverted ? "#a9a9a9"
                                             : platformStyle.colorDisabledLight
            else
                return normalColor
        }
    }
}
