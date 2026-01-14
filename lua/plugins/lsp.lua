-- neovim needs a language server(LS) to which it can talk to.
-- the language server is generally some external process and the editor will communicate to it. neovim will spawn the lsp process and own it for its lifetime.
-- to avoid setting up lsp manually using vim.lsp.buf or whatever the apis are, i am using nvim-lspconfig plugin
-- :help lspconfig-all will tell give you the list of LS available and info on how to install them. easy way to install is through your package manager but i am using mason.nvim.

return {
  -- LSP Configuration Library (Required for vim.lsp.enable to find configs)
  {
    "neovim/nvim-lspconfig",
    -- No config function needed if using vim.lsp.enable(), 
    -- we just need the plugin in the runtime path.
  },

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
