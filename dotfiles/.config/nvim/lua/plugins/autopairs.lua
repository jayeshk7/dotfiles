-- this plugin is for autocomplete of closing brackets

return {
  {
    'windwp/nvim-autopairs',
    -- this says defer loading this plugin until user enters in insert mode
    event = "InsertEnter",
    config = true
    -- use opts = {} for passing setup options
    -- this is equivalent to setup({}) function
  }
}
