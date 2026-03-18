def main [] {
    use nupm/nupm
    nupm install --path nupm --force
    cd nu_plugin_clipboard
    git apply ../nu_plugin_clipboard.patch
    cd -
    nupm install --path nu_plugin_clipboard --force
}
