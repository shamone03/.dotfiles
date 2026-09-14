use path.nu
export def --env project_source [] {
    cd (open (path rev-parse .sources.txt --ceiling ($env.projects)/.builds) --raw)
}

export def --env build [--release] {
    if $release {
        cd (just output --binary)/Release
    } else {
        cd (just output --binary)/Debug
    }
}

export def --env projects [] {
    cd $env.projects
}

export def --env git-root [] {
    cd (git rev-parse --show-toplevel)
}
