export def list [] {
    http get https://api.github.com/repos/tinted-theming/schemes/git/trees/spec-0.11?recursive=1
        | get tree
        | get path
        | where { $in =~ "base[1|2][6|4]/.*\\.yaml" }
        | each { $in | str replace --regex "base../" "" | str replace ".yaml" "" }
        | uniq
}

def show [theme: string]: nothing -> record {
    try {
        http get $"https://raw.githubusercontent.com/tinted-theming/schemes/refs/heads/spec-0.11/base24/($theme).yaml"
    } catch {
        http get $"https://raw.githubusercontent.com/tinted-theming/schemes/refs/heads/spec-0.11/base16/($theme).yaml"
    }
}

export def nvim [theme: string] {
    let theme_scheme = show $theme
    let base = $theme_scheme | get system 
    $"($base)-($theme)" | save ($nu.temp-dir)/shmn/theme.txt --force
}

export def wezterm [theme: string@list] {
    let wezterm_dir = [$env.projects .dotfiles wezterm] | path join
    let theme_scheme = show $theme
    $theme_scheme
        | rename --column { system: scheme }
        | flatten --all palette
        | into record
        | to yaml
        | save ($wezterm_dir | path join base16-theme.yml) --force
    touch ($wezterm_dir | path join wezterm.lua)
    let result_theme = $theme_scheme | get system | $"($in)-($theme)"

    print $"Updated wezterm theme to ($result_theme)"
}

export def lazygit [theme: string@list] {
    let lazygit_dir = [$env.projects .dotfiles lazygit] | path join
    http get $"https://raw.githubusercontent.com/tinted-theming/tinted-lazygit/refs/heads/main/themes/base16-($theme).yml"
        | merge (open ($lazygit_dir | path join config.yml) | reject gui)
        | save ($lazygit_dir | path join config.yml) --force
    print $"Updated lazygit theme to base16-($theme)"
}

export def all [theme: string@list] {
    wezterm $theme
    lazygit $theme
    nvim $theme
}

