-- neovim needs a language server(LS) to which it can talk to.
-- the language server is generally some external process and the editor will communicate to it. neovim will spawn the lsp process and own it for its lifetime.
-- :help lspconfig-all will tell give you the list of LS available and info on how to install them. easy way to install is through your package manager but i am using mason.nvim.
-- EDIT: moved nvim-lspconfig to mason.lua - it is added as dependency for mason-lspconfig. this file is just for lazydev

return {
  {
    "folke/lazydev.nvim",
    ft = "lua",
    opts = {
      library = {
        { path = "${3rd}/luv/library", words = { "vim%.uv" } },
      },
    },
  },
}
