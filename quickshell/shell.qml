import Quickshell
import Quickshell.Io
import QtQuick

PanelWindow {
    SystemClock {
        id: clock
        precision: SystemClock.Seconds
    }

    property FileView themeFile: FileView {
        path: "/home/shamone/.cache/shmn/quickshell-base16-theme.json" 
        watchChanges: true
        blockLoading: true
        onFileChanged: this.reload()

        adapter: JsonAdapter {
            id: base16
            property string base00
            property string base01
            property string base02
            property string base03
            property string base04
            property string base05
            property string base06
            property string base07
            property string base08
            property string base09
            property string base0A
            property string base0B
            property string base0C
            property string base0D
            property string base0E
            property string base0F
        }
    }

    anchors.top: true
    anchors.left: true
    anchors.right: true
    implicitHeight: 20
    color: base16.base00

    Text {
        anchors.centerIn: parent
        text: Qt.formatDateTime(clock.date, "hh:mm:ss")
        color: base16.base05
        font.pixelSize: 15
    }
}
