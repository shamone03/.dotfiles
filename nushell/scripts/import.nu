export def justfile [] {
    try {
        mklink .justfile (
      [$env.projects .dotfiles cpp justfile]
      | path join
      | str replace '/' '\' --all
    )
    }
}

export def vscode [] {
    cp $"($env.projects)/.dotfiles/vscode/.vscode/" . --recursive --verbose
}
