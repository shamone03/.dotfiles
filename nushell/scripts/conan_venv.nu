use miscellaneous.nu *
use private.nu
const last_env_name = $"($nu.temp-dir)/shmn/.env"

export def home []: nothing -> string {
    $"($env.HOMEDRIVE)/v"
}

def completions [] {
    let venv_home = home
    ls $venv_home | get name | each { $in | path basename }
}

def get-last-env-name [name?: string]: nothing -> string {
    if not ($last_env_name | path dirname | path exists) {
        mkdir ($last_env_name | path dirname)
    }
    if not ($last_env_name | path exists) {
        { SHMN_CONAN_VENV_NAME: develop, CONAN_HOME: (home | path join develop | str replace '\' '/' --all) } | into env | save $last_env_name --force
    }

    match $name {
        null => {
            open $last_env_name | get SHMN_CONAN_VENV_NAME
        }
        _ => {
            { SHMN_CONAN_VENV_NAME: $name, CONAN_HOME: (home | path join $name | str replace '\' '/' --all) } | into env | save $last_env_name --force
            $name
        }
    }
}

export def --env switch [name?: string@completions, --aims-version: string, --update] {
    if not $update and $aims_version != null {
        error make {msg: "idk how to deal with this"}
    }

    let name = get-last-env-name $name

    open $last_env_name | load-env

    if $aims_version != null {
        error make "Cannot specify aims version for conan 2 yet"
    }
    if $update or not ([$env.CONAN_HOME profiles default] | path join | path exists) {
        conan config install $private.conan_config
    }
    glob $"($env.projects)/.dotfiles/conan-profiles/*" | each {
        let fileName = [ $env.CONAN_HOME profiles ( $in | path basename ) ] | path join | str replace '/' '\\' --all;
        let filePath = $in | str replace '/' '\\' --all;
        if (not ( $fileName | path exists )) {
            mklink $fileName $filePath | print
        }
    }
    "tools.microsoft.msbuild:vs_version=18" | save ([$env.CONAN_HOME "global.conf"] | path join) --force --progress
}

export def --env exit [] {
    if ($env has SHMN_CONAN_VENV_NAME) {
        hide-env CONAN_USER_HOME CONAN_HOME SHMN_CONAN_VENV_NAME --ignore-errors
        use ../starship.nu
    }
}

export def --env remove [name: string@completions] {
    let venv_dir = home | path join $name

    rm $venv_dir --recursive --verbose --permanent
    rm $last_env_name
    if ($env has SHMN_CONAN_VENV_NAME) and ($env | get SHMN_CONAN_VENV_NAME | $in == $name) {
        hide-env CONAN_USER_HOME CONAN_HOME SHMN_CONAN_VENV_NAME --ignore-errors
        use ../starship.nu
    }
}

export def list [] {
    let venv_home = home
    ls $venv_home | get name
}
