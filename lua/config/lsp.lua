local capabilities = require('blink.cmp').get_lsp_capabilities()
vim.lsp.config('*', {
  capabilities = capabilities,
})

vim.lsp.enable({ "clangd" })
vim.lsp.enable({ "lua_ls" })
vim.lsp.enable({ "pyright" })

vim.diagnostic.config({
  virtual_text = true,
})

vim.keymap.set("n", "<space>d", vim.diagnostic.open_float, {
  desc = "Open diagnostics float",
})

vim.api.nvim_create_autocmd('LspAttach', {
  callback = function (args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if not client then return end

    local map = function (keys, func, desc)
      vim.keymap.set('n', keys, func, { buffer = args.buf, desc = 'LSP: ' .. desc })
    end

    map('gd', vim.lsp.buf.definition, 'Goto Definition')
    map('<leader>gd', vim.lsp.buf.definition, 'Goto Definition')
    map('gr', require('telescope.builtin').lsp_references, 'Goto References')
    map('<leader>rn', vim.lsp.buf.rename, 'Rename')
    map('K', vim.lsp.buf.hover, 'Hover Documentation')
    map('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')

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
