use starship.nu
# use linux.nu *;
# use hyprutils.nu *;
use windows.nu *
use find_in_parent.nu *
use search.nu
use scripts/conan_venv.nu
use scripts/project_info.nu

mkdir $"($nu.cache-dir)"
carapace _carapace nushell | save --force $"($nu.cache-dir)/carapace.nu"

source $"($nu.cache-dir)/carapace.nu"

$env.PATH ++= [$"($env.projects)/.dotfiles/nushell/nupm/plugins/bin"]
$env.STARSHIP_CONFIG = $"($env.projects)/.dotfiles/starship/starship.toml"
$env.config.buffer_editor = "nvim"
$env.config.show_banner = false
$env.config.rm.always_trash = true
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

def "import mprocs" [--out(-o): string = .] {
    cp (["S:/aryah" tools aims.mprocs.yaml] | path join) $"($out)/mprocs.yaml"
}

def "import justfile" [] {
    mklink .justfile (
        [$env.projects .dotfiles cpp justfile]
        | path join
        | str replace '/' '\' --all
    )
}

def "import vscode" [] {
    cp $"($env.projects)/.dotfiles/vscode/.vscode/" . --recursive --verbose
}

def open-repo [--pull-request(-p)] {
    mut link = git config --get remote.origin.url | str trim
    let branch = git branch --show-current | str trim
    let attach = $"/pullrequestcreate?sourceRef=($branch)"
    if $pull_request {
        $link = [$link, $attach] | str join
    }

    start $link
}

alias l = lazygit
alias y = yazi
alias o = nvim .
alias j = just
alias or = open-repo
alias gh = cd $env.projects
alias gp = cd (git rev-parse --show-toplevel)
alias gb = cd (just output)
alias gs = cd (open (find-in-parent .sources.txt ($env.projects)/.builds) --raw)

def --env y [...args] {
    let tmp = (mktemp -t "yazi-cwd.XXXXXX")
    yazi ...$args --cwd-file $tmp
    let cwd = (open $tmp)
    if $cwd != "" and $cwd != $env.PWD {
        cd $cwd
    }
    rm -fp $tmp
}

def git-root [path?: string] {
    return (git rev-parse --show-toplevel)
}

def get_file_list [path: string] {
    ls **/*
    | where type == file
    | format pattern 'f"{name}",'
    | str join
    | str replace '\' '/' --all
    | str replace '.dll' '{plugin_ext}.dll' --all
    | '[' ++ $in ++ ']'
}

source ( [~/Projects .dotfiles nushell nu_scripts/themes/nu-themes/rose-pine.nu] | path join )

let osc9_9 = if $nu.os-info == "linux" {
    true
} else {
    false
}

$env.config.shell_integration = {
    osc2: true
    osc7: true
    osc8: true
    osc9_9: $osc9_9
    osc133: false
    osc633: true
    reset_application_mode: true
}

$env.config.table.mode = 'reinforced'
$env.config.table.index_mode = 'auto'
$env.config.edit_mode = "emacs"
$env.config.history = {
    file_format: sqlite
    max_size: 1_000_000_000
    sync_on_enter: false
    isolation: true
}

def "nu-complete just" [] {
    (^just --dump --unstable --dump-format json | from json).recipes | transpose recipe data | flatten | where {|row| $row.private == false } | select recipe doc parameters | rename value description
}

def "git-log" [] {
    git log --pretty='%H»¦«%an»¦«%ch»¦«%s' | lines | split column "»¦«" id name date message
}

# @complete external
# def --wrapped j [...args: string] {
#   ^just ...$args
# }
export extern "just" [
    ...recipe: string@"nu-complete just", # Recipe(s) to run, may be with argument(s)
]
$env.config.hooks.pre_prompt = [
{
  let duration = $env.CMD_DURATION_MS | into duration --unit ms
  let last_command = (history | last).command
  if ( ($last_command == "j") or ($last_command | str starts-with "j ") or ($last_command | str starts-with "just") ) and $duration > 10sec {
      let wd = $env.PWD | path relative-to $env.projects
        if $env.LAST_EXIT_CODE == 0 {
          notify --summary $"🟢($wd): ($last_command)" --body $"Completed in ($duration)"
        } else {
          notify --summary $"🔴($wd): ($last_command)" --body $"Completed in ($duration)"
        }
  }
  }
]
