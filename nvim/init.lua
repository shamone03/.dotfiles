vim.g.mapleader = " "
vim.g.maplocalleader = " "
-- vim.g.loaded_netrw = 1
-- vim.g.loaded_netrwPlugin = 1
vim.g.shmn_virtual_text = true
vim.g.shmn_show_tabs = false
vim.g.shmn_animations_enabled = false

vim.opt.backup = true
local is_windows = vim.uv.os_uname().sysname == "Windows_NT"
if is_windows then
    vim.opt.backupdir = "C:/.backup//"
else
    vim.opt.backupdir = "/home/shamone/.nvim-backup//"
end

vim.opt.relativenumber = true
vim.opt.tabstop = 4 -- A TAB character looks like 4 spaces
vim.opt.expandtab = true -- Pressing the TAB key will insert spaces instead of a TAB character
vim.opt.softtabstop = 4 -- Number of spaces inserted instead of a TAB character
vim.opt.shiftwidth = 4 -- Number of spaces inserted when indenting
vim.opt.fixendofline = false
vim.opt.number = true
vim.opt.shell = "nu"
vim.opt.mouse = "a"
vim.opt.undofile = true
vim.opt.signcolumn = "yes"
vim.opt.clipboard = "unnamedplus"
vim.opt.cursorline = true
vim.opt.breakindent = true
vim.opt.fillchars = { eob = " " }
vim.opt.termguicolors = true
vim.opt.list = vim.g.shmn_show_tabs
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }
vim.opt.guifont = "Hurmit Nerd Font Mono"

vim.diagnostic.config({
    signs = {
        text = {
            [vim.diagnostic.severity.ERROR] = " ",
            [vim.diagnostic.severity.WARN] = " ",
            [vim.diagnostic.severity.INFO] = " ",
            [vim.diagnostic.severity.HINT] = " ",
        },
    },
    virtual_text = vim.g.shmn_virtual_text, -- show inline diagnostics
})

local function setup_treesitter()
    vim.pack.add({
        "https://github.com/nvim-treesitter/nvim-treesitter",
    })

    require("nvim-treesitter").setup({
        auto_install = true, -- autoinstall languages that are not installed yet
    })
end

local function setup_lsp()
    vim.pack.add({
        "https://github.com/mason-org/mason.nvim", -- install lang servers
        "https://github.com/mason-org/mason-lspconfig.nvim", -- auto enable lang servers with configs
        "https://github.com/neovim/nvim-lspconfig",
    })
    require("mason").setup()
    require("mason-lspconfig").setup({
        ensure_installed = { "lua_ls", "marksman" },
    })

    local pack_path = vim.fn.stdpath("data") .. "/site/pack"

    require("vim.lsp").config("lua_ls", {
        settings = {
            Lua = {
                runtime = {
                    version = "LuaJIT",
                },
                workspace = {
                    checkThirdParty = false,
                    library = {
                        vim.env.VIMRUNTIME,
                        pack_path, -- points to native pack plugins directory
                    },
                },
            },
        },
    })

    vim.lsp.on_type_formatting.enable()
    vim.lsp.inlay_hint.enable()
    vim.lsp.enable("nushell")
end

---@enum ExplorerType
local ExplorerType = {
    Yazi = "yazi",
    Tree = "nvim-tree",
}

---@param type ExplorerType
local function setup_explorer(type)
    local function setup_nvim_tree()
        vim.pack.add({ "https://github.com/nvim-tree/nvim-tree.lua" })
        ---@type nvim_tree.config
        local nvim_tree_config = {
            view = {
                side = "right",
            },
            renderer = {
                group_empty = true,
            },
            update_focused_file = {
                enable = true,
            },
            modified = {
                enable = true,
            },
            diagnostics = {
                enable = true,
            },
        }

        local function keymaps()
            local explorer = require("nvim-tree.api")
            vim.keymap.set("n", "<leader>e", explorer.tree.toggle, { desc = "Toggle Explorer" })
        end

        require("nvim-tree").setup(nvim_tree_config)
        keymaps()
    end

    local function setup_yazi()
        vim.pack.add({ "https://github.com/mikavilpas/yazi.nvim" })
        local function keymaps()
            local explorer = require("yazi")
            vim.keymap.set("n", "<leader>e", explorer.yazi, { desc = "Show Explorer" })
        end

        require("yazi").setup({})
        keymaps()
    end

    if type == ExplorerType.Yazi then
        setup_yazi()
    elseif type == ExplorerType.Tree then
        setup_nvim_tree()
    end
end

local function setup_autocomplete_menu()
    vim.pack.add({
        "https://github.com/saghen/blink.cmp",
        "https://github.com/saghen/blink.lib",
    })
    local blink = require("blink.cmp")
    blink.build():pwait()
    blink.setup({
        completion = {
            documentation = {
                auto_show = true,
            },
        },
        keymap = {
            preset = "super-tab",
        },
    })
end

local function setup_dashboard()
    vim.pack.add({ "https://github.com/nvimdev/dashboard-nvim" })
    local header = [[
█████╗ ██╗███╗   ███╗███████╗      ██╗███████╗██████╗
██╔══██╗██║████╗ ████║██╔════╝      ██║██╔════╝██╔══██╗
███████║██║██╔████╔██║███████╗█████╗██║███████╗██████╔╝
██╔══██║██║██║╚██╔╝██║╚════██║╚════╝██║╚════██║██╔══██╗
██║  ██║██║██║ ╚═╝ ██║███████║      ██║███████║██║  ██║
╚═╝  ╚═╝╚═╝╚═╝     ╚═╝╚══════╝      ╚═╝╚══════╝╚═╝  ╚═╝]]
    -- header = vim.split(header, "\n"),
    require("dashboard").setup({
        theme = "hyper",
        config = {
            header = vim.split(header, "\n"),
            shortcut = {
                {
                    desc = "󰚰 Update",
                    action = vim.pack.update,
                    group = "DiagnosticWarn",
                    key = "u",
                },
                {
                    desc = " Files",
                    action = "Yazi",
                    group = "DiagnosticInfo",
                    key = "f",
                },
                {
                    desc = "󰈆 Quit",
                    action = vim.cmd.quit,
                    group = "DiagnosticError",
                    key = "q",
                },
                {
                    desc = "󰁯 Restore",
                    action = "ShmnRestoreSession",
                    group = "DiagnosticTrace",
                    key = "s",
                },
            },
            footer = {},
            mru = { cwd_only = true },
        },
    })
end

local function setup_picker()
    vim.pack.add({
        "https://github.com/nvim-lua/plenary.nvim",
        "https://github.com/nvim-telescope/telescope.nvim",
        "https://github.com/nvim-telescope/telescope-ui-select.nvim",
    })
    local picker = require("telescope")
    local actions = require("telescope.actions")
    picker.setup({
        pickers = {
            colorscheme = {
                enable_preview = true,
                ignore_builtins = true,
            },
        },
        defaults = {
            sorting_strategy = "ascending",
            layout_config = {
                prompt_position = "top",
            },
            mappings = {
                i = {
                    ["<C-Down>"] = actions.cycle_history_next,
                    ["<C-Up>"] = actions.cycle_history_prev,
                },
            },
        },
        extensions = {
            ["ui-select"] = {
                -- Pass layout overrides directly into the dropdown theme generator
                require("telescope.themes").get_dropdown({
                    layout_config = {
                        -- 0.8 means 80% of the screen width. You can also use an absolute character count like 80.
                        width = 0.3,
                        height = 0.2,
                    },
                }),
            },
        },
    })
    picker.load_extension("ui-select")

    local function keymaps()
        local telescope = require("telescope.builtin")
        vim.keymap.set("n", "<leader><space>", telescope.find_files, { desc = "Search files" })
        vim.keymap.set("n", "<leader>/", telescope.live_grep, { desc = "Search project" })
        vim.keymap.set("n", "<leader>ss", telescope.lsp_document_symbols, { desc = "Search buffer symbols" })
        vim.keymap.set("n", "<leader>sS", telescope.lsp_workspace_symbols, { desc = "Search workspace symbols" })
        vim.keymap.set("n", "<leader>sd", telescope.diagnostics, { desc = "Search diagnostics" })
        vim.keymap.set("n", "<leader>ut", telescope.colorscheme, { desc = "Pick theme" })
    end

    keymaps()
end

local function setup_tab_bars()
    vim.pack.add({ "https://github.com/akinsho/bufferline.nvim" })
    require("bufferline").setup({
        options = {
            custom_filter = function(buf_number)
                return vim.bo[buf_number].buftype ~= "terminal"
            end,
        },
    })

    local function keymaps()
        local tab_bar = require("bufferline.commands")

        vim.keymap.set("n", "H", function()
            tab_bar.cycle(-1)
        end, { desc = "Go to previous buffer" })
        vim.keymap.set("n", "L", function()
            tab_bar.cycle(1)
        end, { desc = "Go to next buffer" })
        vim.keymap.set({ "n", "t" }, "<C-c>", function()
            if not vim.bo.modified then
                tab_bar.unpin_and_close()
            else
                vim.notify("Buffer unsaved!!!")
            end
        end, { desc = "Close current buffer" })
    end
    keymaps()
end

local function setup_keymap_hints()
    vim.pack.add({ "https://github.com/folke/which-key.nvim" })
    local wk = require("which-key")
    ---@class wk.Opts
    local config = {
        preset = "helix",
        keys = {
            scroll_down = "<c-s-d>",
            scroll_up = "<c-s-u>",
        },
    }
    wk.setup(config)
    wk.add({
        { "<leader>s", group = "Search" },
        { "<leader>u", group = "UI" },
        { "<leader>c", group = "Code" },
        { "<leader>g", group = "Git" },
        { "<leader>n", group = "Neovim" },
    })
end

local function setup_common_keymaps()
    local function lsp_keymaps()
        vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "Go to definition" })
        vim.keymap.set({ "i", "n" }, "<A-o>", "<cmd>LspClangdSwitchSourceHeader<CR>", { desc = "Switch source/header" })
        vim.keymap.set({ "n", "x" }, "<leader>f", vim.lsp.buf.format, { desc = "Format current buffer/selection" })
        vim.keymap.set({ "n", "x" }, "<leader>.", function()
            vim.lsp.buf.code_action({ apply = true })
        end, { desc = "Show and/or apply code action" })
        vim.keymap.set({ "n", "x" }, "<leader>ca", vim.lsp.buf.code_action, { desc = "Show code action" })
        vim.keymap.set({ "n", "x" }, "<leader>cd", vim.diagnostic.open_float, { desc = "Show diagnostic" })
        vim.keymap.set({ "i", "n" }, "<C-k>", vim.lsp.buf.signature_help, { desc = "Signature help" })
        vim.keymap.set({ "i", "n" }, "<C-k>", "<Plug>(nvim.lsp.ctrl-s)")
    end

    local function editor_keymaps()
        vim.keymap.set({ "i", "n" }, "<C-s>", vim.cmd.write, { desc = "Write buffer" })
        vim.keymap.set({ "n" }, "<leader>w", vim.cmd.write, { desc = "Write buffer" })
        vim.keymap.set({ "n" }, "<leader>q", vim.cmd.quit, { desc = "Quit" })
        vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear highlights" })
        vim.keymap.set("n", "<leader>ud", function()
            vim.g.shmn_virtual_text = not vim.g.shmn_virtual_text
            vim.diagnostic.config({ virtual_text = vim.g.shmn_virtual_text })
        end, { desc = "Toggle inline diagnostics" })
        vim.keymap.set("n", "<leader>us", function()
            vim.g.shmn_show_tabs = not vim.g.shmn_show_tabs
            vim.opt_local.list = vim.g.shmn_show_tabs
        end, { desc = "Toggle show tabs" })
        vim.keymap.set("n", "<leader>nr", vim.cmd.restart, { desc = "Restart neovim" })

        vim.keymap.set("n", "<A-j>", ":m .+1<CR>==", { desc = "Move line down" })
        vim.keymap.set("n", "<A-k>", ":m .-2<CR>==", { desc = "Move line up" })
        vim.keymap.set("v", "<A-j>", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
        vim.keymap.set("v", "<A-k>", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

        vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Go to Left Window" })
        vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Go to Lower Window" })
        vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Go to Upper Window" })
        vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Go to Right Window" })
        vim.keymap.set("n", "<C-q>", "<C-w>q", { desc = "Close Window" })
        vim.keymap.set("n", "<C-Right>", "<C-w>>", { desc = "Increase window width" })
        vim.keymap.set("n", "<C-Left>", "<C-w><", { desc = "Decrease window width" })
    end

    lsp_keymaps()
    editor_keymaps()
end

local function setup_smooth_scroll()
    vim.pack.add({ "https://github.com/karb94/neoscroll.nvim" })
    require("neoscroll").setup({
        duration_multiplier = 0.25,
    })
end

local function setup_smooth_cursor()
    vim.pack.add({ "https://github.com/sphamba/smear-cursor.nvim" })
    require("smear_cursor").setup()
end

local function setup_git_hints()
    vim.pack.add({ "https://github.com/lewis6991/gitsigns.nvim" })
    require("gitsigns").setup()

    local function keymaps()
        local git = require("gitsigns")
        vim.keymap.set("n", "<leader>gb", function()
            git.blame_line({ full = true })
        end, { desc = "Blame Line" })
        vim.keymap.set("n", "<leader>gB", git.blame, { desc = "Blame Buffer" })
        vim.keymap.set({ "n", "x" }, "<leader>gr", ":Gitsigns reset_hunk<CR>", { desc = "Reset Hunk" })
    end
    keymaps()
end

local function setup_theme()
    vim.pack.add({
        "https://github.com/nvim-tree/nvim-web-devicons",
        "https://github.com/nvim-mini/mini.icons",
        "https://github.com/tinted-theming/tinted-nvim",
    })
    require("tinted-nvim").setup()
    local theme_file = os.getenv("TEMP") .. "/shmn/theme.txt"
    if vim.uv.fs_stat(theme_file) then
        local content = vim.fn.readfile(theme_file)
        local theme = table.concat(content, "\n"):gsub("%s+", "")
        vim.cmd.colorscheme(theme)
    else
        vim.cmd.colorscheme("base24-flexoki-dark")
    end
end

local function setup_terminal()
    vim.pack.add({ "https://github.com/shamone03/shmn-terminal.nvim" })
    require("shmn-terminal").setup({
        width = 0.7,
        height = 0.7,
    })

    local function keymaps()
        local terminal = require("shmn-terminal")
        if is_windows then
            vim.keymap.set({ "n", "t" }, "<C-_>", terminal.shmn_terminal, { desc = "Toggle terminal" })
        else
            vim.keymap.set({ "n", "t" }, "<C-/>", terminal.shmn_terminal, { desc = "Toggle terminal" })
        end
    end
    keymaps()
end

local function setup_autocomplete_pairs()
    vim.pack.add({ "https://github.com/nvim-mini/mini.pairs" })
    require("mini.pairs").setup()
end

local function setup_surround_pairs()
    vim.pack.add({ "https://github.com/nvim-mini/mini.surround" })
    require("mini.surround").setup()
end

local function setup_autocmds()
    vim.api.nvim_create_autocmd("BufReadPost", {
        callback = function()
            local mark = vim.api.nvim_buf_get_mark(0, '"')
            local lcount = vim.api.nvim_buf_line_count(0)
            if mark[1] > 0 and mark[1] <= lcount then
                pcall(vim.api.nvim_win_set_cursor, 0, mark)
            end
        end,
    })
end

local function setup_session_management()
    vim.pack.add({ "https://github.com/shamone03/shmn-sessions.nvim" })
    require("shmn-sessions").setup()
end

setup_autocmds()
setup_common_keymaps()
if vim.g.vscode then
    return
end

setup_lsp()
setup_treesitter()

setup_picker()
setup_tab_bars()
setup_explorer(ExplorerType.Yazi)
setup_autocomplete_menu()
setup_autocomplete_pairs()
setup_surround_pairs()
setup_dashboard()
setup_git_hints()
setup_terminal()
setup_keymap_hints()
setup_session_management()

setup_theme()
if vim.g.neovide then
    return
end
if vim.g.shmn_animations_enabled then
    setup_smooth_scroll()
    setup_smooth_cursor()
end
