local M = {}

M.file_exists = function(path)
    local f = io.open(path, "r")
    if f then
        f:close()
        return true
    end
    return false
end

return M
