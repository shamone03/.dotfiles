-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Environment-variables/
hl.env("PATH", os.getenv("PATH") .. ":" .. os.getenv("HOME") .. "/.cargo/bin")
hl.env("EDITOR", "nvim")
hl.env("VISUAL", "nvim")
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")
hl.env("projects", "/home/shamone/Projects/")
