hl.on("hyprland.start", function ()
    local programs = require("programs")
    hl.exec_cmd(programs.status_bar)
end)
