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

def git-log [] {
    git log --pretty='%H»¦«%an»¦«%ch»¦«%s' | lines | split column "»¦«" id name date message
}
