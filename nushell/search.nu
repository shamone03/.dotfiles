export def google [...query: string] {
    start ($query | str join " " | url encode | $"https://www.google.com/search?q=($in)")
}

export def tfs [...query: string] {
    start ($query | str join " " | url encode | $"https://cn-tfs-ap-01.ad.onepal.com/tfs/CarteNavCollection/_search?text=($in)&type=code")
}

