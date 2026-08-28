use private.nu
export def google [...query: string] {
    start (
        $query
        | str join " "
        | url encode
        | $"https://www.google.com/search?q=($in)"
    )
}

export def tfs [...query: string] {
    start (
        $query
        | str join " "
        | url encode
        | $"($private.tfs_url)/_search?text=($in)&type=code"
    )
}
