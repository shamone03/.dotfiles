-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
vim.o.relativenumber = true
vim.o.tabstop = 4 -- A TAB character looks like 4 spaces
vim.o.expandtab = true -- Pressing the TAB key will insert spaces instead of a TAB character
vim.o.softtabstop = 4 -- Number of spaces inserted instead of a TAB character
vim.o.shiftwidth = 4 -- Number of spaces inserted when indenting
vim.o.fixendofline = false
vim.cmd("set guicursor=a:hor20,i:ver20")
vim.cmd("set number")

vim.g.lazyvim_rust_diagnostics = "rust-analyzer"
vim.o.shell = "nu"

-- -- Check if 'pwsh' is executable and set the shell accordingly
-- if vim.fn.executable("pwsh") == 1 then
-- else
--   vim.o.shell = "powershell"
-- end
--
-- -- Setting shell command flags
-- vim.o.shellcmdflag =
--   "-NoLogo -ExecutionPolicy RemoteSigned -Command [Console]::InputEncoding=[Console]::OutputEncoding=[System.Text.UTF8Encoding]::new();$PSDefaultParameterValues['Out-File:Encoding']='utf8';"
--
-- -- Setting shell redirection
-- vim.o.shellredir = '2>&1 | %{ "$_" } | Out-File %s; exit $LastExitCode'
--
-- -- Setting shell pipe
-- vim.o.shellpipe = '2>&1 | %{ "$_" } | Tee-Object %s; exit $LastExitCode'
--
-- -- Setting shell quote options
-- vim.o.shellquote = ""
-- vim.o.shellxquote = ""
