export def find-in-parent [filename: string, ceiling: string] {
    mut current = (pwd)
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
                return $target
            } else {
                return null
            }
        }
    }
}
