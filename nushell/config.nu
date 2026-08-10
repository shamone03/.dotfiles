use starship.nu
const os_tools = if $nu.os-info.name == "linux" { "linux.nu" } else { "windows.nu" }
const scripts = if $nu.os-info.name == "linux" { null } else { "scripts" }

use $os_tools *
use $scripts *

if $nu.is-interactive {
    try {
        conan_venv switch
    }
    source ( [~/Projects .dotfiles nushell nu_scripts/themes/nu-themes/rose-pine.nu] | path join )
}

if (not ($nu.cache-dir | path join "carapace.nu" | path exists)) {
    mkdir $"($nu.cache-dir)"
    carapace _carapace nushell | save --force $"($nu.cache-dir)/carapace.nu"
}
source $"($nu.cache-dir)/carapace.nu"
$env.CARAPACE_LENIENT = 1
$env.CARAPACE_EXCLUDES = "go"
$env.PATH ++= [$"($env.projects)/.dotfiles/nushell/nupm/plugins/bin"]
$env.STARSHIP_CONFIG = $"($env.projects)/.dotfiles/starship/starship.toml"
$env.JUST_COMMAND_COLOR = "purple"
$env.JUST_HIGHLIGHT = true
$env.YAZI_CONFIG_HOME = $"($env.projects)/.dotfiles/yazi/"

def --env y [...args] {
    let tmp = (mktemp -t "yazi-cwd.XXXXXX")
    yazi ...$args --cwd-file $tmp
    let cwd = (open $tmp)
    if $cwd != "" and $cwd != $env.PWD {
        cd $cwd
    }
    rm -fp $tmp
}

alias l = lazygit
alias y = yazi
alias o = nvim
alias j = just
alias or = open-repo
alias gh = goto projects
alias gp = goto git-root
alias gb = goto build
alias gs = goto source

$env.config.shell_integration = {
    osc2: true
    osc7: true
    osc8: true
    osc9_9: ($nu.os-info == "linux")
    osc133: false
    osc633: true
    reset_application_mode: true
}

$env.config.buffer_editor = "nvim"
$env.config.show_banner = false
$env.config.rm.always_trash = true
$env.config.table.mode = 'reinforced'
$env.config.table.index_mode = 'auto'
$env.config.edit_mode = "vi"
$env.config.history = {
    file_format: sqlite
    max_size: 1_000_000_000
    sync_on_enter: false
    isolation: true
}

# Disable prompt from Nushell Because it is duplicated with that of Starship
$env.PROMPT_INDICATOR_VI_NORMAL = ""
$env.PROMPT_INDICATOR_VI_INSERT = ""

# Use cursor shapes to differentiate instead
$env.config.cursor_shape.vi_insert = "blink_line"
$env.config.cursor_shape.vi_normal = "blink_block"
$env.config.hooks.pre_prompt = [
    {
        let duration = $env.CMD_DURATION_MS | into duration --unit ms
        let last_command = (history | last).command
        if (($last_command == "j") or ($last_command | str starts-with "j ") or ($last_command | str starts-with "just")) and $duration > 10sec {
            let wd = $env.PWD | path relative-to $env.projects
            if $env.LAST_EXIT_CODE == 0 {
                notify --summary $"🟢($wd): ($last_command)" --body $"Completed in ($duration)"
            } else {
                notify --summary $"🔴($wd): ($last_command)" --body $"Completed in ($duration)"
            }
        }
    }
]
$env.config.menus ++= [
    {
        name: just_menu,
        only_buffer_difference: true,
        style: {
            text: white,
            selected_text: magenta,
            description_text: yellow
        }
        marker: "# ",
        type: {
            layout: columnar,
            page_size: 24
        },
        source: { |buffer, position|
            just --dump --unstable --dump-format json
            | from json
            | get recipes
            | transpose recipe data
            | where $in.data.private == false
            | each {
                {
                    value: $"just ($in.recipe)",
                    description: $in.data.doc?
                }
            }
        }
    }
]
$env.config.keybindings ++= [
    {
        name: open_yazi,
        modifier: CONTROL,
        keycode: char_y,
        mode: [vi_insert vi_normal emacs]
        event: [
            {
                send: executehostcommand,
                cmd: "y"
            }
        ]
    },
    {
        name: open_lazygit,
        modifier: CONTROL,
        keycode: char_g,
        mode: [vi_insert vi_normal emacs]
        event: [
            {
                send: executehostcommand,
                cmd: "l"
            }
        ]
    },
    {
        name: just_menu,
        modifier: ALT
        keycode: char_t
        mode: [vi_insert vi_normal emacs]
        event: {
            until: [
                { send: menu name: just_menu }
                { send: menupagenext }
            ]
        }
    },
    {
        name: just_build,
        modifier: CONTROL,
        keycode: char_b,
        mode: [vi_insert vi_normal emacs]
        event: [
            {
                send: executehostcommand,
                cmd: "just build"
            }
        ]
    },
    {
        name: just_default,
        modifier: CONTROL_SHIFT,
        keycode: char_b,
        mode: [vi_insert vi_normal emacs]
        event: [
            {
                send: executehostcommand,
                cmd: "just default"
            }
        ]
    },
    {
        name: no_ctrl_q,
        modifier: CONTROL,
        keycode: char_q,
        mode: [emacs, vi_normal, vi_insert]
        event: null
    }
]
