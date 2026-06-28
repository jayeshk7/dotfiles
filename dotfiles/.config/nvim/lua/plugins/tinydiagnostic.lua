return {
  {
    "rachartier/tiny-inline-diagnostic.nvim",
    event = "VeryLazy",
    priority = 1000,
    config = function()
      require("tiny-inline-diagnostic").setup({
        options = {
          multilines = {
            enabled = true,
          },
          add_messages = {
            display_count = true,
          },
          set_arrow_to_diag_color = true,
        },

      })
      vim.diagnostic.config({ virtual_text = false }) -- Disable Neovim's default virtual text diagnostics

    end,
  }
}
