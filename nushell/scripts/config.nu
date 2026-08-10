export def lazygit [] {
    ^nvim ...(glob $"($env.projects)/.dotfiles/lazygit/*.yml" --no-dir)
}

export def nvim [] {
    ^nvim $"($env.projects)/.dotfiles/nvim"
}

export def starship [] {
    ^nvim ...(glob $"($env.projects)/.dotfiles/starship/*.toml" --no-dir)
}

export def wezterm [] {
    ^nvim $env.WEZTERM_CONFIG_FILE
}

export def justfile [] {
    ^nvim $"($env.projects)/.dotfiles/cpp/justfile"
}
