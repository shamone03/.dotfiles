export def google [...query: string] {
    start (
        $query
        | str join " "
        | url encode
        | $"https://www.google.com/search?q=($in)"
    )
}

