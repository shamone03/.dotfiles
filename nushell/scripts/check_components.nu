export def get_uncommon []: string -> list<string> {
    let root = (git rev-parse --show-toplevel);
    let project = (open $in | select packages | values | flatten);
    let common = (open $"($root)/release/common-components.json" | select packages | values | flatten);
    $project | where not ($common has $it)
}
export def get_common []: string -> list<string> {
    let root = (git rev-parse --show-toplevel);
    let project = (open $in | select packages | values | flatten);
    let common = (open $"($root)/release/common-components.json" | select packages | values | flatten);
    $project | where ($common has $it)
}

def "main fix" [project_file: string] {
    $project_file | get_uncommon | { packages: $in } | to json --indent 4 | save $project_file -f
}

def main [project_file: string] {
    $project_file | get_uncommon
}