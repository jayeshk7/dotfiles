-- basically what lazy does (simplified) - downloads a git repo and puts it in the runtimepath. and then allows you to run some code to load and configure the plugins

--Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end

-- this says put lazy into the runtimepath for neovim so we can require() it in neovim.
-- because we know neovim only finds the required modules inside of its runtimepath
-- so you can find all the plugins path if you do :echo nvim_list_runtimepath();
-- and then if you want to delete any plugin just delete its directory (you can find it using runtimepath()) and then remove the plugin import in lazy setup below.
vim.opt.runtimepath:prepend(lazypath)

-- Setup lazy.nvim
-- there are two ways to configure your plugins 
-- 1. you can either directly put your plugins here inside spec table like { spec = { {'folke/tokyonight'}, { .. } .. }
-- 2. you can have diff files for each plugin and then import them all like shown below.
-- you can disable a plugin by sending an argument enable = false in the plugin file (example shown in mini.lua)

require("lazy").setup({
  spec = {
    { import = "plugins" }
  },
  change_detection = { notify = false },
  performance = { rtp = { reset = false } },
})
