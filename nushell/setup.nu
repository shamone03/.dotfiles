def main [] {
    use nupm/nupm
    nupm install --path nupm --force
    git apply nu_plugin_clipboard.patch
    nupm install --path nu_plugin_clipboard --force
}
