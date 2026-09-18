export def justfile [] {
    try {
        mklink .justfile ([$env.projects .dotfiles cpp justfile] | path join | str replace '/' '\' --all)
    }
}

export def vscode [] {
    use ../constants.nu
    if $constants.is_work {
        cp $"($env.projects)/.dotfiles/vscode/work.vscode/" . --recursive --verbose
    }
}
