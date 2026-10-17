local utils = require("utils")

-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Environment-variables/
hl.env("PATH", os.getenv("PATH") .. ":" .. os.getenv("HOME") .. "/.cargo/bin")
hl.env("EDITOR", "nvim")
hl.env("VISUAL", "nvim")
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")
if utils.file_exists("/home/shamone/.icons/ATER-yellow/index.theme") then
    hl.env("HYPRCURSOR_THEME", "ATER-yellow")
else
    hl.notification.create({
        text = "[SHMN] Could not set cursor",
        timeout = 3000,
        icon = 3,
    })
end
hl.env("projects", "/home/shamone/Projects/")
