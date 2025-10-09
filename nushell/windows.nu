export-env {
    if $nu.os-info.name == "windows" {
        $env.YAZI_FILE_ONE = $"($env.LOCALAPPDATA)/Programs/Git/usr/bin/file.exe"
        $env.PATH ++= [ $"($env.ProgramFiles)/Microsoft Visual Studio/2022/Community/VC/Tools/Llvm/x64/bin/" ]
        $env.projects = $"($env.HOMEPATH)/Projects"
    }
}
