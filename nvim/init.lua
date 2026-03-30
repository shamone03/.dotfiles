vim.g.mapleader = " "
vim.g.maplocalleader = " "
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

local virtual_text = true
vim.diagnostic.config({
	signs = {
		text = {
			[vim.diagnostic.severity.ERROR] = " ",
			[vim.diagnostic.severity.WARN] = " ",
			[vim.diagnostic.severity.INFO] = " ",
			[vim.diagnostic.severity.HINT] = " ",
		},
	},
	virtual_text = virtual_text, -- show inline diagnostics
})
vim.opt.list = true
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }

vim.pack.add({
	"https://github.com/nvim-treesitter/nvim-treesitter",
	"https://github.com/saghen/blink.cmp",
	"https://github.com/neovim/nvim-lspconfig",
	"https://github.com/folke/which-key.nvim",
	"https://github.com/nvim-lua/plenary.nvim",
	"https://github.com/nvim-telescope/telescope.nvim",
	"https://github.com/nvim-tree/nvim-web-devicons",
	"https://github.com/mason-org/mason.nvim", -- install lang servers
	"https://github.com/mason-org/mason-lspconfig.nvim", -- auto enable lang servers with configs
    "https://github.com/rose-pine/neovim",
}, { confirm = false })

require("mason").setup()
require("mason-lspconfig").setup()

require("blink.cmp").setup({
	completion = {
		documentation = {
			auto_show = true,
		},
	},
	fuzzy = {
		prebuilt_binaries = {
			force_version = "v1.*",
		},
	},
    keymap = {
        preset = "super-tab"
    }
})

require("telescope").setup({})
local telescope = require("telescope.builtin")
vim.keymap.set("n", "<leader><space>", telescope.find_files, { desc = "Search files" })
vim.keymap.set("n", "<leader>/", telescope.live_grep, { desc = "Search project" })
vim.keymap.set("n", "gd", vim.lsp.buf.definition)
vim.keymap.set("n", "<M-o>", "<cmd>LspClangdSwitchSourceHeader<CR>")
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")
vim.keymap.set("i", "<C-s>", "<Esc><cmd>w<CR>")
vim.keymap.set("n", "<C-s>", "<cmd>w<CR>")
vim.keymap.set("n", "<leader>od", function ()
    virtual_text = not virtual_text
    vim.diagnostic.config({virtual_text = virtual_text})
end, { desc = "Toggle inline diagnostics" } )
vim.lsp.on_type_formatting.enable()
vim.lsp.inlay_hint.enable()
-- vim.lsp.completion.enable()
-- vim.keymap.set('i', '<C-space>', function()
--   vim.lsp.completion.get()
-- end)
-- vim.cmd[[set completeopt+=menuone,noselect,popup]]
-- vim.lsp.start({
--   name = 'clangd',
--   on_attach = function(client, bufnr)
--     vim.lsp.completion.enable(true, client.id, bufnr, {
--       autotrigger = true,
--       convert = function(item)
--         return { abbr = item.label:gsub('%b()', '') }
--       end,
--     })
--   end,
-- })
vim.cmd("colorscheme rose-pine")
-- equivalent to :TSUpdate
-- require("nvim-treesitter.install").update("all")
-- require("nvim-treesitter").setup({
--     auto_install = true, -- autoinstall languages that are not installed yet
-- })
