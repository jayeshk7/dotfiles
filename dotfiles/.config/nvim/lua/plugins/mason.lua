-- mason is just an installation tool for our LSP. so you dont have to go and install each lsp separately.
-- but this will put your lsp binaries in a place where practically only neovim can find them. so if you have other text editors you will have to install the lsp separately for them. 
-- skip this if you're installing LS yourself and putting it on path. nvim-lspconfig is enough 

return {
  "williamboman/mason-lspconfig.nvim",
  opts = {
    ensure_installed = {
      "clangd",
      "lua_ls",
      "pyright",
      "marksman",
      "jdtls",
    }
  },
  dependencies = {
    {
      "williamboman/mason.nvim",
      config = function ()
        require'mason'.setup({})
      end
    },
    -- LSP Configuration Library (Required for vim.lsp.enable to find configs)
    -- nvim-lspconfig is a community maintained repo for configs of many LSPs. so if you use this your installed LSP will get a default config
    -- you don't have to set it up. really helpful. you can change the config according to your need as well if needed
    -- you can just do vim.enable.lsp("ls_name") and automatically the config will be attached to that lsp.
    "neovim/nvim-lspconfig"
  },
  config = function ()
    require("mason-lspconfig").setup {
    automatic_enable = {
      exclude = {
        "jdtls",
      }
    }
  }
  end,
}
