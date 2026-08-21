export def get-aims-latest [] {
    let out_file = ($nu.temp-dir)/AIMS_Latest.zip
    if ($out_file | path exists) {
        rm ($out_file) --force --verbose
    }
    http get http://cn-appaf-p01.ad.onepal.com:8081/artifactory/aims-builds-daily/All/AIMS_Latest.zip --raw
        | into binary
        | save ($nu.temp-dir)/AIMS_Latest.zip --force --raw
    ouch decompress ($nu.temp-dir)/AIMS_Latest.zip --dir ($env.HOMEDRIVE)/AIMS_Latest
}

export def open-repo [--pull-request(-p)] {
    mut link = git config --get remote.origin.url | str trim
    let branch = git branch --show-current | str trim
    let attach = $"/pullrequestcreate?sourceRef=($branch)"
    if $pull_request {
        $link = [$link, $attach] | str join
    }

    start $link
}

export def git-root [] {
    return (git rev-parse --show-toplevel)
}

export def git-log [] {
    git log --pretty='%H»¦«%an»¦«%ch»¦«%s' | lines | split column "»¦«" id name date message
}

export def "from env" []: string -> record {
# https://github.com/nushell/nu_scripts/blob/eb43c8c0df920f4fc7f15058939c66ff89be9d61/modules/formats/from-env.nu
  lines
    | split column '#' # remove comments
    | get column0
    | parse "{key}={value}"
    | update value {
        str trim                        # Trim whitespace between value and inline comments
          | str trim -c '"'             # unquote double-quoted values
          | str trim -c "'"             # unquote single-quoted values
          | str replace -a "\\n" "\n"   # replace `\n` with newline char
          | str replace -a "\\r" "\r"   # replace `\r` with carriage return
          | str replace -a "\\t" "\t"   # replace `\t` with tab
    }
    | transpose -r -d
}

export def "into env" []: record -> string {
    transpose key value | each { $"($in.key)=($in.value)" } | str join "\n"
}
