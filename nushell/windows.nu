export-env {
    if $nu.os-info.name == "windows" {
        $env.YAZI_FILE_ONE = [($env.LOCALAPPDATA)/Programs $env.PROGRAMFILES]
        | each { $"($in)/Git/usr/bin/file.exe" }
        | where { $in | path exists }
        | str replace --all '\' '/'
        | first
        | default null
        $env.PATH ++= [ $"($env.ProgramFiles)/LLVM/bin" ]
        $env.projects = $"($env.HOMEDRIVE)($env.HOMEPATH)/Projects" | str replace --all '\' '/'
        $env.project_builds = $"($env.HOMEDRIVE)/b" | str replace --all '\' '/'
    }
}
