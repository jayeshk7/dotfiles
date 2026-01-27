-- this is for file navigation. you can fzf through your cwd in which neovim is opened. still not configured fully. i am using it for basic file navigation only

return {
  {
    'nvim-telescope/telescope.nvim',
    branch = 'master',
    dependencies = {
      'nvim-lua/plenary.nvim',
      { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' }
    },
    config = function()
      require('telescope').setup {
        pickers = {
          find_files = {
            theme = "ivy"
          },
          help_tags = {
            theme = "ivy"
          }
        },
        extensions = {
          fzf = {}
        }
      }

      require('telescope').load_extension('fzf')

    -- if you want to change something in your config quickly then you can do <space>en (edit neovim)
    -- no matter which directory you're in, if you do <space>en then you will always telescope files of your neovim config.
      vim.keymap.set("n", "<leader>ff", require('telescope.builtin').find_files)
      vim.keymap.set("n", "<leader>fg", require('telescope.builtin').live_grep)
      vim.keymap.set("n", "<leader>fh", require('telescope.builtin').help_tags)
      vim.keymap.set("n", "<leader>en", function()
        require('telescope.builtin').find_files {
          cwd = vim.fn.stdpath("config")
        }
      end)
    end
  }
}
