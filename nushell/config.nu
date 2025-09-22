$env.config.buffer_editor = "nvim"
$env.config.show_banner = false

$env.YAZI_FILE_ONE = $"($env.LOCALAPPDATA)/Programs/Git/usr/bin/file.exe"
$env.nvimconfig = $"($env.LOCALAPPDATA)/nvim/init.lua"
$env.projects = $"($env.USERPROFILE)/Projects/"
$env.YAZI_CONFIG_HOME = $"($env.projects)/.dotfiles/yazi/" 
$env.CONAN_USE_ALWAYS_SHORT_PATHS = "True"
$env.STARSHIP_CONFIG = $"($env.projects)/.dotfiles/starship/starship.toml"
# $env.PATH ++= [ $"($env.ProgramFiles)/Microsoft Visual Studio/2022/Community/VC/Tools/Llvm/x64/bin/" ]

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

export-env { $env.STARSHIP_SHELL = "nu"; load-env {
    STARSHIP_SESSION_KEY: (random chars -l 16)
    PROMPT_MULTILINE_INDICATOR: (
        ^'starship.exe' prompt --continuation
    )

    # Does not play well with default character module.
    # TODO: Also Use starship vi mode indicators?
    PROMPT_INDICATOR: ""

    PROMPT_COMMAND: {||
        # jobs are not supported
        (
            ^'starship.exe' prompt
                --cmd-duration $env.CMD_DURATION_MS
                $"--status=($env.LAST_EXIT_CODE)"
                --terminal-width (term size).columns
        )
    }

    config: ($env.config? | default {} | merge {
        render_right_prompt_on_last_line: true
    })

    PROMPT_COMMAND_RIGHT: {||
        (
            ^'starship.exe' prompt
                --right
                --cmd-duration $env.CMD_DURATION_MS
                $"--status=($env.LAST_EXIT_CODE)"
                --terminal-width (term size).columns
        )
    }
}}

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
