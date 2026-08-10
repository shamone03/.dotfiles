export def list-local-updates [] {
    use std
    ls */*justfile
    | where type == symlink
    | get name
    | path dirname
    | each { |package|
          try {
              just ($package)/versions --json | from json
          } catch {
              null
          }
    }
    | where $it != null
    | where {
        $in.versions
        | where source == "Local Cache"
        | first
        | get version
        | is-not-empty
    }
    | where {
        let local_cache_version = $in.versions | where source == "Local Cache" | first | get version;
        let remote_version = $in.versions | where source == conan2-local | first | get version;
        $local_cache_version != $remote_version
    }
}
