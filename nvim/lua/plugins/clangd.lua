return {
  "neovim/nvim-lspconfig",
  servers = {
    clangd = {
      keys = {
        { "<A-Enter>", "<cmd>LspClangdSwitchSourceHeader<cr>", desc = "Switch Source/Header (C/C++)" },
      },
    },
  },
}
