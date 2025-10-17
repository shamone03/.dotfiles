export def update-wallpaper [wallpaper_path: string] {
    hyprctl hyprpaper reload $",($wallpaper_path)"; wal -i (hyprctl hyprpaper listloaded) -se -a fff
}

export def random-wallpaper [wallpaper_dir?: string] {
    mut current = hyprctl hyprpaper listloaded
    let get_random = { || glob ($wallpaper_dir | default $"($env.HOME)/Pictures/wallpapers/**") --no-dir | shuffle | first }
    mut random = do $get_random
    while $random == $current {
        $random = do $get_random
    }
    update-wallpaper $random
}

