-- this is for filetree navigation and all. very nice

return {
  {
    'stevearc/oil.nvim',
    opts = {},
    -- dependencies = { { "echasnovski/mini.icons", opts = {} } },
    dependencies = { "nvim-tree/nvim-web-devicons" },
    -- Lazy loading is not recommended because it is very tricky to make it work correctly in all situations.
    lazy = false,
    config = function()
      require'oil'.setup {
        view_options = {
          show_hidden = true,
        }
      }
      vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc ='Opens oil at the current working file level' } )
    end
  }
}

-- remember you can use telescope while inside oil tree. can be useful

-- to navigate in the parent directory press '-'. 
-- to close the oil tree and go back to the file you were editing press CTRL-c
