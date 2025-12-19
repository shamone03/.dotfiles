def main [] {
    let root = (git rev-parse --show-toplevel);

    let links = (glob $"($root)/**/{compile_commands.json}") ++ [$"($env.projects)/cmake-build-smith/additional-files/.clang-format"] ++ [$"($env.projects)/cmake-build-smith/additional-files/.clang-tidy"];

    ls ...$links | each {
        let fileName = $in.name | path basename;
        let filePath = $in.name;
        if (not ( $fileName | path exists )) {
            mklink $fileName $filePath;
        }
	}

    if (not ( $"($root)/CMakeUserPresets.json" | path exists )) {
        let presets = glob $"($root)/**/CMakePresets.json";
        if ($presets | is-not-empty) {
            ls ...$presets | first | $in.name |
                {
                    version: 4,
                    include: [ $in ]
                }
             | save CMakeUserPresets.json -f
        }
    }
    let clangd = "CompileFlags:
    Add: ['-std:c++20', '-std:c++latest']";
    $clangd | save .clangd --force
}
