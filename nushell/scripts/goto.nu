use path.nu
export def --env project_source [] {
    cd (open (path find-in-parent .sources.txt ($env.projects)/.builds) --raw)
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
