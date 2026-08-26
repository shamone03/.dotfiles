export const temp_dir = if $nu.os-info.name == "linux" { ($nu.home-dir)/.cache/shmn } else { ($nu.temp-dir)/shmn }
