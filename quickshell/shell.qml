import Quickshell
import Quickshell.Io
import QtQuick
import Quickshell.Hyprland
import QtQuick.Layouts

PanelWindow {
    Theme {
        id: theme
    }
    anchors.top: true
    anchors.left: true
    anchors.right: true
    margins.bottom: 5
    
    implicitHeight: 20
    color: theme.adapter.base00

    RowLayout {
        anchors.left: parent.left
        spacing: 10
        SystemClock {
            id: clock
            precision: SystemClock.Seconds
        }

        Repeater {
            model: 9

            Text {
                property var isActive: Hyprland.focusedWorkspace?.id === (index + 1) // this is javascript??
                text: index + 1
                font.pixelSize: 15
                font.bold: isActive
                color: if (isActive) {
                    theme.adapter.base0A
                } else if (mouseArea.containsMouse) {
                    theme.adapter.base01
                } else {
                    theme.adapter.base05
                }
                MouseArea {
                    id: mouseArea
                    hoverEnabled: true
                    anchors.fill: parent
                    onClicked: Hyprland.dispatch(`hl.dsp.focus({ workspace = ${index + 1} })`)
                }
            }
        }

    }
    Text {
        anchors.right: parent.right
        text: Qt.formatDateTime(clock.date, "hh:mm:ss")
        color: theme.adapter.base05
        font.pixelSize: 15
    }
}
