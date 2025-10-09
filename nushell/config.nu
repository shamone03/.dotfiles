use starship.nu;

use linux.nu *;
use windows.nu *;

$env.config.buffer_editor = "nvim"
$env.config.show_banner = false

$env.projects = $"~/Projects/"

$env.YAZI_CONFIG_HOME = $"($env.projects)/.dotfiles/yazi/"
$env.STARSHIP_CONFIG = $"($env.projects)/.dotfiles/starship/starship.toml"

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

def get_file_list [path: string] {
    ls **/*
    | where type == file
    | format pattern 'f"{name}",'
    | str join
    | str replace '\' '/'  --all
    | str replace '.dll' '{plugin_ext}.dll' --all
    | '[' ++ $in ++ ']'
}

def search [...query: string] {
    start ($query | str join " " | url encode | $"https://www.google.com/search?q=($in)")
}

cd $env.projects
