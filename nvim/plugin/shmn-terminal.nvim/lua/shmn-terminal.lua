local M = {}

---@class ShmnTermState
---@field buf_id integer
---@field win_id integer

---@class ShmnTermConfiguration
---@field enabled boolean
---@field width decimal
---@field height decimal

---@type ShmnTermState
local shmn_term_state = {
    buf_id = -1,
    win_id = -1,
}

---@type ShmnTermConfiguration
local configuration = {
    enabled = true,
    width = 0.8,
    height = 0.5,
}

local function toggle_terminal()
    local win_height = vim.o.lines
    local win_width = vim.o.columns

    local term_height = math.floor(win_height * configuration.height)
    local term_width = math.floor(win_width * configuration.width)

    local term_pos_row = math.floor((win_height - term_height) / 2)
    local term_pos_col = math.floor((win_width - term_width) / 2)

    if not vim.api.nvim_win_is_valid(shmn_term_state.win_id) then
        if not vim.api.nvim_buf_is_valid(shmn_term_state.buf_id) then
            shmn_term_state.buf_id = vim.api.nvim_create_buf(false, true)
        end
        shmn_term_state.win_id = vim.api.nvim_open_win(shmn_term_state.buf_id, true, {
            relative = "editor",
            height = term_height,
            width = term_width,
            col = term_pos_col,
            row = term_pos_row,
            border = "rounded",
        })
        if vim.bo[shmn_term_state.buf_id].buftype ~= "terminal" then
            vim.api.nvim_win_call(shmn_term_state.win_id, function()
                vim.cmd.terminal()
                vim.cmd.startinsert()
            end)
        else
            vim.api.nvim_win_call(shmn_term_state.win_id, function()
                vim.cmd.startinsert()
            end)
        end
    else
        if vim.api.nvim_win_is_valid(shmn_term_state.win_id) then
            vim.api.nvim_win_hide(shmn_term_state.win_id)
        end
    end
end

M.shmn_terminal = function()
    if configuration.enabled then
        toggle_terminal()
    end
end

---@param user_configuration ShmnTermConfiguration | nil
M.setup = function(user_configuration)
    configuration = user_configuration or configuration
end

return M
