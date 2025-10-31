use starship.nu;

use linux.nu *;
use hyprutils.nu *;
# use windows.nu *;

use search.nu;

$env.STARSHIP_CONFIG = $"($env.projects)/.dotfiles/starship/starship.toml"
$env.config.buffer_editor = "nvim"
$env.config.show_banner = false

$env.YAZI_CONFIG_HOME = $"($env.projects)/.dotfiles/yazi/"

def "config lazygit" [] {
	nvim ...(glob $"($env.projects)/.dotfiles/lazygit/*.yml" --no-dir)
}

def "config nvim" [] {
	nvim ...(glob $"($env.projects)/.dotfiles/nvim/**" --no-dir)
}

def "config starship" [] {
	nvim ...(glob $"($env.projects)/.dotfiles/starship/*.toml" --no-dir)
}

def open-repo [--pull-request (-p)] {
    mut link = git config --get remote.origin.url | str trim
    let branch = git branch --show-current | str trim
    let attach = $"/pullrequestcreate?sourceRef=($branch)"
	if $pull_request {
		$link = [ $link, $attach ] | str join
    }

	start $link
}

alias l = lazygit
alias y = yazi
alias o = nvim .
alias or = open-repo
alias gh = cd $env.projects
alias gp = cd (git rev-parse --show-toplevel)

# change dir after exiting yazi
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
    | str replace '\' '/'  --all
    | str replace '.dll' '{plugin_ext}.dll' --all
    | '[' ++ $in ++ ']'
}

source ( [~/Projects .dotfiles nushell nu_scripts/themes/nu-themes/rose-pine.nu] | path join )

let osc9_9 = if $nu.os-info == "linux" {
	true
} else {
	false
}

# Starship
$env.config.shell_integration = {
  # osc2 abbreviates the path if in the home_dir, sets the tab/window title, shows the running command in the tab/window title
  osc2: true
  # osc7 is a way to communicate the path to the terminal, this is helpful for spawning new tabs in the same directory
  osc7: true
  # osc8 is also implemented as the deprecated setting ls.show_clickable_links, it shows clickable links in ls output if your terminal supports it
  osc8: true
  # osc9_9 is from ConEmu and is starting to get wider support. It's similar to osc7 in that it communicates the path to the terminal
  osc9_9: $osc9_9,
  # osc133 is several escapes invented by Final Term which include the supported ones below.
  # 133;A - Mark prompt start
  # 133;B - Mark prompt end
  # 133;C - Mark pre-execution
  # 133;D;exit - Mark execution finished with exit code
  # This is used to enable terminals to know where the prompt is, the command is, where the command finishes, and where the output of the command is
  osc133: false
  # osc633 is closely related to osc133 but only exists in visual studio code (vscode) and supports their shell integration features
  # 633;A - Mark prompt start
  # 633;B - Mark prompt end
  # 633;C - Mark pre-execution
  # 633;D;exit - Mark execution finished with exit code
  # 633;E - NOT IMPLEMENTED - Explicitly set the command line with an optional nonce
  # 633;P;Cwd=<path> - Mark the current working directory and communicate it to the terminal
  # and also helps with the run recent menu in vscode
  osc633: true
  # reset_application_mode is escape \x1b[?1l and was added to help ssh work better
  reset_application_mode: true
}
