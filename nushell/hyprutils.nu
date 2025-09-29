
export def update-wallpaper [wallpaper_path: string] {
    hyprctl hyprpaper reload $",($wallpaper_path)"; wal -i (hyprctl hyprpaper listloaded) -se -a fff
}

export def random-wallpaper [wallpaper_dir?: string] {
    ls ($wallpaper_dir | default $"($env.HOME)/Pictures/wallpapers/") | shuffle | first | update-wallpaper $in.name
}
