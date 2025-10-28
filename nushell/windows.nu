export-env {
    if $nu.os-info.name == "windows" {
        $env.YAZI_FILE_ONE = $"($env.LOCALAPPDATA)/Programs/Git/usr/bin/file.exe"
        $env.PATH ++= [ $"($env.ProgramFiles)/LLVM/bin" ]
        $env.projects = $"($env.HOMEPATH)/Projects"
        $env.CONAN_USE_ALWAYS_SHORT_PATHS = "True"
    }
}
