const current_wallpaper_path = "~/.cache/shmn/current_wallpaper.txt" | path expand
export def "to log" [path: string]: string -> nothing {
    let log_file = $"($env.projects | path expand)/.dotfiles/logs/($path)";
    if (not ($log_file | path exists )) {
        mkdir ($log_file | path dirname)
        touch $log_file
    }
    $"[(date now)] ($in)\n" | save $log_file --append --force
}

export def update-theme [--use-wallpaper] {
    if ($use_wallpaper) {
        wal -i (open $current_wallpaper_path --raw | str trim) -se -a fff
    } else {
        wal --theme random
    }
    pywalfox update o+e>| to text | to log theme-switch.log
}

export def update-wallpaper [wallpaper_path: string] {
  let path = $wallpaper_path | path expand
    hyprctl hyprpaper wallpaper $",($path)"
    $path | str trim | save $current_wallpaper_path --force
    update-theme --use-wallpaper
}

export def random-wallpaper [wallpaper_dir?: string] {
  if not ($current_wallpaper_path | path exists) {
    mkdir ($current_wallpaper_path | | path dirname)
    touch $current_wallpaper_path
  }
    mut current = open ~/.cache/shmn/current_wallpaper.txt --raw | str trim | default ""
    let get_random = { || glob ($wallpaper_dir | default $"($env.HOME)/Pictures/wallpapers/**") --no-dir | shuffle | first }
    mut random = do $get_random
    while $random == $current {
        $random = do $get_random
    }
    update-wallpaper $random
}

export def "config hypr" [] {
	nvim ...(glob $"($env.projects)/.dotfiles/hypr/*.conf" --no-dir)
}

