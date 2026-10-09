use ../constants.nu
const lazygit_theme_config_path = ($constants.temp_dir)/lazygit-base16-theme.yaml
const wezterm_theme_config_path = ($constants.temp_dir)/wezterm-base16-theme.yaml
const nvim_theme_config_path = ($constants.temp_dir)/nvim-base16-theme.txt
const tinted_theme_config_path = ($constants.temp_dir)/tinted-theme.yaml
const hypr_theme_config_path = ($constants.temp_dir)/hypr-base16-theme.csv
const quickshell_theme_config_path = ($constants.temp_dir)/quickshell-base16-theme.json

export def list [] {
    http get https://api.github.com/repos/tinted-theming/schemes/git/trees/spec-0.11?recursive=1
        | get tree
        | get path
        | where { $in =~ "base[1|2][6|4]/.*\\.yaml" }
        | each { $in | str replace --regex "base../" "" | str replace ".yaml" "" }
        | uniq
}

export def info [theme?: string@list, --preview]: nothing -> record {
    let theme_scheme = if $theme == null and ($tinted_theme_config_path | path exists) {
        open $tinted_theme_config_path
    } else if $theme == null and (not ($tinted_theme_config_path | path exists)) {
      error make "Theme not initialized"
    } else {
        try {
            http get $"https://raw.githubusercontent.com/tinted-theming/schemes/refs/heads/spec-0.11/base24/($theme).yaml"
        } catch {
            http get $"https://raw.githubusercontent.com/tinted-theming/schemes/refs/heads/spec-0.11/base16/($theme).yaml"
        }
    }
    if $preview {
        $theme_scheme | update palette { $in | items { |k v| $"(ansi $v)($k): ($v)(ansi reset)" } }
    } else {
        $theme_scheme
    }
}

def update-cache [theme: string] {
    let theme_scheme = info $theme
    let base = $theme_scheme | get system 
    $theme_scheme | save $tinted_theme_config_path --force
}

export def nvim [theme: string] {
    let theme_name = info $theme | $"($in.system)-($theme)"
    $theme_name | save $nvim_theme_config_path --force
    print $"Updated neovim theme to ($theme_name)"
}

export def wezterm [theme: string@list] {
    let theme_scheme = info $theme
    $theme_scheme
        | rename --column { system: scheme }
        | flatten --all palette
        | into record
        | to yaml
        | save $wezterm_theme_config_path --force
    touch ([$env.projects .dotfiles wezterm wezterm.lua] | path join)
    let result_theme = $theme_scheme | get system | $"($in)-($theme)"

    print $"Updated wezterm theme to ($result_theme)"
}

export def lazygit [theme: string@list] {
    let lazygit_dir = [$env.projects .dotfiles lazygit] | path join
    let theme_scheme = info $theme
    let palette = $theme_scheme.palette
    
    let lazygit_theme = try {
        http get $"https://raw.githubusercontent.com/tinted-theming/tinted-lazygit/refs/heads/main/themes/base16-($theme).yml"
    } catch {
        print $"Creating custom lazygit theme"
        {
            gui: {
                theme: {
                    activeBorderColor: [$palette.base0D, bold],
                    inactiveBorderColor: [$palette.base03],
                    searchingActiveBorderColor: [$palette.base09],
                    optionsTextColor: [$palette.base0D],
                    selectedLineBgColor: [$palette.base02],
                    cherryPickedCommitBgColor: [$palette.base03],
                    cherryPickedCommitFgColor: [$palette.base0D],
                    markedBaseCommitFgColor: [$palette.base0D],
                    unstagedChangesColor: [$palette.base08],
                    defaultFgColor: [$palette.base05]
                }
            }
        }
    }

    $lazygit_theme | save $lazygit_theme_config_path --force
    print $"Updated lazygit theme to base16-($theme)"
}

export def hypr [theme: string@list] {
    let theme_scheme = info $theme
    let palette = $theme_scheme.palette

    $"($palette.base08),($palette.base0A)" | save $hypr_theme_config_path --force
    hyprctl reload | ignore
    print $"Updated hypr theme to ($theme_scheme.system)-($theme)"
}

export def quickshell [theme: string@list] {
    let theme_scheme = info $theme
    let palette = $theme_scheme.palette
    $palette | to json | save $quickshell_theme_config_path --force
    print $"Updated quickshell theme to ($theme_scheme.system)-($theme)"
}

export def all [theme: string@list] {
    update-cache $theme
    wezterm $theme
    lazygit $theme
    nvim $theme
    if $nu.os-info.name == "linux" {
      hypr $theme
      quickshell $theme
    }
}

