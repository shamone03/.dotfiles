export def --env switch [name] {
    let venv_home = $"C:($env.projects)"
    let venv_dir = [$venv_home virtual_environments $name] | path join

    $env.SHMN_CONAN_VENV = $"(ansi deeppink2)Conan: ($name)(ansi reset)";

    let conan_version = conan --version
        | parse '{conan} {_} {major}.{minor}.{patch}'
        | get major
        | get 0

    if $conan_version == "1" {
        error make { msg: "no conan 1 support" }
    } else if $conan_version == "2" {
        $env.CONAN_USER_HOME = ($venv_dir | path join ".conan2" | str replace '\' '/' --all)
        $env.CONAN_HOME = $env.CONAN_USER_HOME
        conan config install http://cn-appaf-p01.ad.onepal.com:8081/artifactory/generic-local/config/Conan2Config.zip
        cp ~/Projects/.dotfiles/conan-profiles/* ([$env.CONAN_HOME profiles/] | path join) --verbose --force
    }

    use ../starship.nu;
    let old_prompt = $env.PROMPT_COMMAND;
    $env.PROMPT_COMMAND = {|| $"($env.SHMN_CONAN_VENV)(do $old_prompt)"}

    print $"(ansi green)CONAN_USER_HOME=($env.CONAN_USER_HOME)(ansi reset)"
}
