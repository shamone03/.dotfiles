TEMP_DIR = os.getenv("HOME") .. "/.cache"

local function file_exists(path)
    local f = io.open(path, "r")
    if f then
        f:close()
        return true
    end
    return false
end

local function shmn_get_theme()
    local theme_path = TEMP_DIR .. "/shmn/hypr-base16-theme.csv"
    local top_left = "#33ccffee"
    local bottom_right = "#00ff99ee"
    if file_exists(theme_path) then
        local f = io.open(theme_path, "r")
        if f then
            local raw_left, raw_right = string.match(f:read("a"), "([^,]+),([^,]+)")

            if raw_left and raw_right then
                top_left = raw_left:lower()
                bottom_right = raw_right:lower()
            end

            f:close()
        end
    end
    return top_left, bottom_right
end

local top_left, bottom_right = shmn_get_theme()

hl.config({
    general = {
        col = {
            active_border = { colors = { string.format("%s", top_left), string.format("%s", bottom_right) }, angle = 45 },
            inactive_border = "rgba(595959aa)",
        },
    }
})
