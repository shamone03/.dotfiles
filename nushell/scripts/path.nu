# Search for filename in parent directories until given ceiling
export def rev-parse [filename: string, --ceiling(-c): string, --floor(-f): string] {
    mut current = $floor | default (pwd)
    loop {
        let target = $current | path join $filename
        if ($target | path exists) {
            return $target
        }

        if $current == ($current | path dirname) {
            return null
        }
        $current = ($current | path dirname)

        if $current == ($ceiling | path expand) or $current == ($env.HOMEDRIVE | path expand) {
            let target = $current | path join $filename
            if ($target | path exists) {
                return $target | path expand
            } else {
                return null
            }
        }
    }
}

# Replace '\' with '/'
export def forward-slash []: string -> string {
    $in | str replace '\' '/' --all
}
