import Quickshell
import Quickshell.Io
import QtQuick

FileView {
    path: "/home/shamone/.cache/shmn/quickshell-base16-theme.json" 
    watchChanges: true
    blockLoading: true
    onFileChanged: this.reload()

    adapter: JsonAdapter {
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

        property string base10
        property string base11
        property string base12
        property string base13
        property string base14
        property string base15
        property string base16
        property string base17
    }
}
