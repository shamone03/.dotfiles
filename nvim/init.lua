vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
vim.g.shmn_virtual_text = true
vim.g.shmn_show_tabs = false

vim.opt.backup = true
vim.opt.backupdir = "C:/.backup//"
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
    require("mason-lspconfig").setup()

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
    vim.lsp.enable("lua_ls")
    vim.lsp.enable("nushell")
end

local function setup_explorer()
    vim.pack.add({ "https://github.com/nvim-tree/nvim-tree.lua" })
    ---@type nvim_tree.config
    local nvim_tree_config = {
        view = {
            side = "right",
        },
        renderer = {
            group_empty = true,
        },
    }
    require("nvim-tree").setup(nvim_tree_config)
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
                    action = "NvimTreeToggle",
                    group = "DiagnosticInfo",
                    key = "f",
                },
                {
                    desc = "󰈆 Quit",
                    action = vim.cmd.quit,
                    group = "DiagnosticError",
                    key = "q",
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
    picker.setup({
        defaults = {
            sorting_strategy = "ascending",
            layout_config = {
                prompt_position = "top",
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
end

local function setup_tab_bars()
    vim.pack.add({ "https://github.com/akinsho/bufferline.nvim" })
    require("bufferline").setup()
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
end

local function setup_keymaps()
    local picker = require("telescope.builtin")
    local explorer = require("nvim-tree.api")
    local tab_bar = require("bufferline.commands")
    local git = require("gitsigns")

    vim.keymap.set("n", "<leader><space>", picker.find_files, { desc = "Search files" })
    vim.keymap.set("n", "<leader>/", picker.live_grep, { desc = "Search project" })
    vim.keymap.set("n", "<leader>e", explorer.tree.toggle, { desc = "Toggle Explorer" })
    vim.keymap.set("n", "<leader>s", picker.lsp_document_symbols, { desc = "Search buffer symbols" })
    vim.keymap.set("n", "<leader>S", picker.lsp_workspace_symbols, { desc = "Search buffer symbols" })
    vim.keymap.set("n", "<leader>d", picker.diagnostics, { desc = "Search diagnostics" })
    vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "Go to definition" })
    vim.keymap.set("n", "H", function()
        tab_bar.cycle(-1)
    end, { desc = "Go to previous buffer" })
    vim.keymap.set("n", "L", function()
        tab_bar.cycle(1)
    end, { desc = "Go to next buffer" })
    vim.keymap.set("n", "<C-c>", function()
        if not vim.bo.modified then
            tab_bar.unpin_and_close()
        else
            vim.notify("Buffer unsaved!!!")
        end
    end, { desc = "Close current buffer" })
    vim.keymap.set({ "i", "n" }, "<A-o>", "<cmd>LspClangdSwitchSourceHeader<CR>", { desc = "Switch source/header" })
    vim.keymap.set({ "i", "n" }, "<A-F>", vim.lsp.buf.format, { desc = "Format current buffer" })
    vim.keymap.set({ "i", "n" }, "<C-s>", vim.cmd.write, { desc = "Write buffer" })
    vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear highlights" })
    vim.keymap.set("n", "<leader>ud", function()
        vim.g.shmn_virtual_text = not vim.g.shmn_virtual_text
        vim.diagnostic.config({ virtual_text = vim.g.shmn_virtual_text })
    end, { desc = "Toggle inline diagnostics" })
    vim.keymap.set("n", "<leader>us", function()
        vim.g.shmn_show_tabs = not vim.g.shmn_show_tabs
        vim.opt_local.list = vim.g.shmn_show_tabs
    end, { desc = "Toggle show tabs" })

    vim.keymap.set("n", "<A-j>", ":m .+1<CR>==", { desc = "Move line down" })
    vim.keymap.set("n", "<A-k>", ":m .-2<CR>==", { desc = "Move line up" })
    vim.keymap.set("v", "<A-j>", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
    vim.keymap.set("v", "<A-k>", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

    vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Go to Left Window" })
    vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Go to Lower Window" })
    vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Go to Upper Window" })
    vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Go to Right Window" })
    vim.keymap.set("n", "<C-q>", "<C-w>q", { desc = "Close Window" })

    vim.keymap.set({ "n", "i", "x" }, "<leader>.", function()
        vim.lsp.buf.code_action({ apply = true })
    end, { desc = "Show and/or apply code action" })

    vim.keymap.set("n", "<leader>gb", function()
        git.blame_line({ full = true })
    end, { desc = "Blame Line" })
    vim.keymap.set("n", "<leader>gB", git.blame, { desc = "Blame Buffer" })
    vim.keymap.set({ "n", "x" }, "<leader>gr", ":Gitsigns reset_hunk<CR>", { desc = "Reset Hunk" })
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
end

local function setup_theme()
    vim.pack.add({
        "https://github.com/rose-pine/neovim",
        "https://github.com/nvim-tree/nvim-web-devicons",
        "https://github.com/nvim-mini/mini.icons",
    })
    vim.cmd.colorscheme("rose-pine")
end

local function setup_autocomplete_pairs()
    vim.pack.add({ "https://github.com/windwp/nvim-autopairs" })
    require("nvim-autopairs").setup()
end

setup_lsp()
setup_treesitter()

setup_picker()
setup_tab_bars()
setup_explorer()
setup_autocomplete_menu()
setup_autocomplete_pairs()
setup_dashboard()
setup_git_hints()
setup_keymaps()
setup_keymap_hints()

setup_theme()
setup_smooth_scroll()
setup_smooth_cursor()
