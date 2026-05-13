def completions [] {
    let venv_home = $"($env.HOMEDRIVE)/v"
    ls $venv_home | get name | each { $in | path basename }
}

export def --env switch [name: string@completions, --aims-version: string, --update] {
    let conan_version = conan --version
    | parse '{conan} {_} {major}.{minor}.{patch}'
    | get major
    | get 0

    if not $update and $aims_version != null {
        error make {msg: "idk how to deal with this"}
    }

    if $conan_version == "1" {
        let venv_home = $"($env.HOMEDRIVE)/v"
        let venv_dir = [
            $venv_home
            $"($name)_conan-($conan_version)"
        ] | path join

        $env.CONAN_USER_HOME = ($venv_dir | path join | str replace '\' '/' --all)
        $env.CONAN_HOME = $env.CONAN_USER_HOME
        $env.SHMN_CONAN_VENV_NAME = $"($name)_conan-($conan_version)"
        if $update or not ([$env.CONAN_HOME .conan profiles default] | path join | path exists) {
            conan config install http://cn-appaf-p01.ad.onepal.com:8081/artifactory/generic-local/config/ConanConfig.zip
        }
        if $aims_version != null {
            let remote = $"http://cn-appaf-p01.ad.onepal.com:8081/artifactory/api/conan/conan-release-v($aims_version)"
            let remote_name = $"cn-conan-v($aims_version)"
            conan remote rename cn-conan $remote_name
            conan remote update $remote_name $remote
        }
        r#'tools.microsoft.msbuild:vs_version=18
tools.cmake.cmaketoolchain:generator=Visual Studio 18 2026'# | save ([$venv_dir ".conan" "global.conf"] | path join) --force --progress
    } else if $conan_version == "2" {
        let venv_home = $"($env.HOMEDRIVE)/v"
        let venv_dir = [$venv_home $name] | path join

        if $aims_version != null {
            error make "Cannot specify aims version for conan 2 yet"
        }
        $env.CONAN_USER_HOME = ($venv_dir | path join | str replace '\' '/' --all)
        $env.CONAN_HOME = $env.CONAN_USER_HOME
        $env.SHMN_CONAN_VENV_NAME = $name
        if $update or not ([$env.CONAN_HOME profiles default] | path join | path exists) {
            conan config install http://cn-appaf-p01.ad.onepal.com:8081/artifactory/generic-local/config/Conan2Config.zip
        }
        glob $"($env.projects)/.dotfiles/conan-profiles/*" | each {
            let fileName = [ $env.CONAN_HOME profiles ( $in | path basename ) ] | path join | str replace '/' '\\' --all;
            let filePath = $in | str replace '/' '\\' --all;
            if (not ( $fileName | path exists )) {
                mklink $fileName $filePath | print
            }
        }
        "tools.microsoft.msbuild:vs_version=18" | save ([$venv_dir "global.conf"] | path join) --force --progress
    }
    if $conan_version == "1" {
        $env.SHMN_CONAN_VENV_PROMPT = $"(ansi deeppink2)Conan 1: ($name)(ansi reset)"
        if $aims_version != null {
            $env.SHMN_CONAN_VENV_PROMPT = $"(ansi deeppink2)Conan 1: ($name) v($aims_version)(ansi reset)"
        }
    } else if $conan_version == "2" {
        $env.SHMN_CONAN_VENV_PROMPT = $"(ansi deeppink2)Conan: ($name)(ansi reset)"
    }

    use ../starship.nu
    let old_prompt = $env.PROMPT_COMMAND
    $env.PROMPT_COMMAND = {|| $"($env.SHMN_CONAN_VENV_PROMPT)(do $old_prompt)" }

    print $"(ansi green)CONAN_USER_HOME=($env.CONAN_USER_HOME)(ansi reset)"
}

export def --env remove [name: string@completions] {
    let conan_version = conan --version
    | parse '{conan} {_} {major}.{minor}.{patch}'
    | get major
    | get 0
    let venv_home = $"($env.HOMEDRIVE)/v"
    let venv_dir = if $conan_version == "2" {
        [$venv_home $name] | path join
    } else if $conan_version == "1" {
        [
            $venv_home
            $"($name)_conan-($conan_version)"
        ] | path join
    }

    rm $venv_dir --recursive --verbose
    try {
        hide-env SHMN_CONAN_VENV_PROMPT CONAN_USER_HOME CONAN_HOME
    }
    use ../starship.nu
}

export def list [] {
    let venv_home = $"($env.HOMEDRIVE)/v"
    ls $venv_home | select name
}
