export-env {
    if $nu.os-info.name == "linux" {
        $env.projects = "~/Projects"
    }
}

export def "arch-update" [] {
    sudo pacman -S --color always --noconfirm --refresh --sysupgrade --verbose
}

export def torrent [url: string, save_path?: string] {
    kdeconnect-cli -l | lines | first | parse "- {device}:{_}" | kdeconnect-cli -n $in.0.device --ping-msg "Beginning torrent download 🙏"
    mullvad connect
    sleep 5sec

    try {
        qbittorrent --skip-dialog=true --save-path=( $save_path | default /media/Storage/movies/ ) $url
    } catch {
        kdeconnect-cli -n "Galaxy S21 5G" --ping-msg "Torrent download failed ☹️"
    }

    mullvad disconnect
    sleep 5sec

    kdeconnect-cli --refresh
    kdeconnect-cli -l | lines | first | parse "- {device}:{_}" | kdeconnect-cli -n $in.0.device --ping-msg "Torrent download finished 💯"
}

