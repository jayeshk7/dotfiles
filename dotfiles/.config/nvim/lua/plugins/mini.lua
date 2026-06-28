-- lua/plugins/mini.lua
-- this is just for statusline nothing else

return {
  {
    'echasnovski/mini.nvim',
    -- enable = false,
    config = function()
      local statusline = require 'mini.statusline'
      statusline.setup { use_icons = true }
    end
  }
}
