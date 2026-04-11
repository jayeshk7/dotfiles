local capabilities = require('blink.cmp').get_lsp_capabilities()

-- after nvim v0.11+ lsp should be enabled and configured not with require("lspconfig") 
-- but by using vim.lsp.config()
-- so the flow should be lsp.config() -> lsp.enable() -> nvim_create_autocmd('LspAttach') (in case you want some on_attach functionality)
-- check this - https://www.reddit.com/r/neovim/comments/1nmh99k/beware_the_old_nvimlspconfig_setup_api_is/
vim.lsp.config('*', {
  capabilities = capabilities,
})

-- NOW because i have mason-lspconfig i dont have to do this anymore. they are automatically enabled.
-- vim.lsp.enable({ "lua_ls" })
-- vim.lsp.enable({ "clangd" })
-- vim.lsp.enable({ "pyright" })

vim.keymap.set("n", "<space>d", vim.diagnostic.open_float, { desc = "Open diagnostics float" })

vim.api.nvim_create_autocmd('LspAttach', {
  callback = function (args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if not client then return end
    vim.notify('LSP Attached: ' .. client.name, vim.log.levels.INFO, { title = 'LSP' })

    -- many of these keymaps are just default LSP keymaps but i am writing them down so i remember them & can remap easily if needed
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, { desc = 'Goto Definition'})
    vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, { desc = 'Goto Declaration'})
    vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, { desc = 'Code Actions'})
    vim.keymap.set('n', '<leader>gr', require('telescope.builtin').lsp_references, { desc = 'Goto References'})
    vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, { desc = 'Rename'})
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, { desc = 'Hover Documentation'})

    if client:supports_method('textDocument/documentHighlight') then
      local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })

      vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
        buffer = args.buf,
        group = highlight_augroup,
        callback = vim.lsp.buf.document_highlight,
      })

      vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
        buffer = args.buf,
        group = highlight_augroup,
        callback = vim.lsp.buf.clear_references,
      })
    end
  end
})
