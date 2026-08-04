use starship.nu
const os_tools = if $nu.os-info.name == "linux" { "linux.nu" } else { "windows.nu" }
const scripts = if $nu.os-info.name == "linux" { null } else { "scripts" }

use $os_tools *
use $scripts *

if $nu.is-interactive {
    try {
        conan_venv switch
    }
}
use find_in_parent.nu *
use search.nu

mkdir $"($nu.cache-dir)"
carapace _carapace nushell | save --force $"($nu.cache-dir)/carapace.nu"
source $"($nu.cache-dir)/carapace.nu"
$env.CARAPACE_LENIENT = 1
$env.CARAPACE_EXCLUDES = "go"
$env.PATH ++= [$"($env.projects)/.dotfiles/nushell/nupm/plugins/bin"]
$env.STARSHIP_CONFIG = $"($env.projects)/.dotfiles/starship/starship.toml"
$env.JUST_COMMAND_COLOR = "purple"
$env.JUST_HIGHLIGHT = true
$env.YAZI_CONFIG_HOME = $"($env.projects)/.dotfiles/yazi/"

def "config lazygit" [] {
    nvim ...(glob $"($env.projects)/.dotfiles/lazygit/*.yml" --no-dir)
}

def "config nvim" [] {
    nvim $"($env.projects)/.dotfiles/nvim"
}

def "config starship" [] {
    nvim ...(glob $"($env.projects)/.dotfiles/starship/*.toml" --no-dir)
}

def "config wezterm" [] {
    nvim $env.WEZTERM_CONFIG_FILE
}

def "config justfile" [] {
    nvim $"($env.projects)/.dotfiles/cpp/justfile"
}

def "import justfile" [] {
    try {
        mklink .justfile (
      [$env.projects .dotfiles cpp justfile]
      | path join
      | str replace '/' '\' --all
    )
    }
}

def "import vscode" [] {
    cp $"($env.projects)/.dotfiles/vscode/.vscode/" . --recursive --verbose
}

def "history today" [] {
    history | where start_timestamp > ((date now) - 12hr)
}

def get-aims-latest [] {
    let out_file = ($nu.temp-dir)/AIMS_Latest.zip
    if ($out_file | path exists) {
        rm ($out_file) --force --verbose
    }
    http get http://cn-appaf-p01.ad.onepal.com:8081/artifactory/aims-builds-daily/All/AIMS_Latest.zip --raw
        | into binary
        | save ($nu.temp-dir)/AIMS_Latest.zip --force --raw
    ouch decompress ($nu.temp-dir)/AIMS_Latest.zip --dir ($env.HOMEDRIVE)/AIMS_Latest
}

module version {
    def levels [] {
        [major minor patch]
    }

    export def bump [level: string@levels, --dry] {
        let version = just version | str trim
        let updated = $version | into semver | semver bump $level
        if (not $dry) {
            open conanfile.py | str replace $version { $updated | to text } | save conanfile.py --force
        }
        print $"($version) -> ($updated)"
    }
}
use version;

def open-repo [--pull-request(-p)] {
    mut link = git config --get remote.origin.url | str trim
    let branch = git branch --show-current | str trim
    let attach = $"/pullrequestcreate?sourceRef=($branch)"
    if $pull_request {
        $link = [$link, $attach] | str join
    }

    start $link
}

def --env "go source" [] {
    cd (open (find-in-parent .sources.txt ($env.projects)/.builds) --raw)
}

def --env "go build" [--release] {
    if $release {
        cd (just output --binary)/Release
    } else {
        cd (just output --binary)/Debug
    }
}

def git-root [] {
    return (git rev-parse --show-toplevel)
}

alias l = lazygit
alias y = yazi
alias o = nvim
alias j = just
alias or = open-repo
alias gh = cd $env.projects
alias gp = cd (git-root)
alias gb = go build
alias gs = go source

def --env y [...args] {
    let tmp = (mktemp -t "yazi-cwd.XXXXXX")
    yazi ...$args --cwd-file $tmp
    let cwd = (open $tmp)
    if $cwd != "" and $cwd != $env.PWD {
        cd $cwd
    }
    rm -fp $tmp
}

def git-log [] {
    git log --pretty='%H»¦«%an»¦«%ch»¦«%s' | lines | split column "»¦«" id name date message
}

def get-file-list [path: string] {
    ls **/*
    | where type == file
    | format pattern 'f"{name}",'
    | str join
    | str replace '\' '/' --all
    | str replace '.dll' '{plugin_ext}.dll' --all
    | '[' ++ $in ++ ']'
}

if $nu.is-interactive {
  source ( [~/Projects .dotfiles nushell nu_scripts/themes/nu-themes/rose-pine.nu] | path join )
}

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
