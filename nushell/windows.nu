export-env {
    if $nu.os-info.name == "windows" {
        $env.YAZI_FILE_ONE = $"($env.LOCALAPPDATA)/Programs/Git/usr/bin/file.exe"
        $env.PATH ++= [ $"($env.ProgramFiles)/LLVM/bin" ]
        $env.projects = $"($env.HOMEDRIVE)($env.HOMEPATH)/Projects" | str replace --all '\' '/'
        $env.project_builds = $"($env.HOMEDRIVE)/b" | str replace --all '\' '/'
    }
}
