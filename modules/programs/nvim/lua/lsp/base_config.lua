local M = {}

M.on_attach = function(client, bufnr)
  local map = function(mode, lhs, rhs, desc)
    if desc then
      desc = "LSP: " .. desc
    end
    vim.keymap.set(mode, lhs, rhs, { silent = true, buffer = bufnr, noremap = true, desc = desc })
  end

  -- Standard LSP keymaps
  map('n', 'gd', vim.lsp.buf.definition, 'Go to Definition')
  map('n', 'K', vim.lsp.buf.hover, 'Hover Documentation')
  map('n', 'gi', vim.lsp.buf.implementation, 'Go to Implementation')
  map('n', '<leader>sh', vim.lsp.buf.signature_help, 'Signature Help')
  map('n', '<leader>D', vim.lsp.buf.type_definition, 'Type Definition')
  map('n', '<leader>rn', vim.lsp.buf.rename, 'Rename Symbol')
  map('n', '<leader>ca', vim.lsp.buf.code_action, 'Code Action')
  map('n', 'gr', vim.lsp.buf.references, 'Go to References')

  -- Diagnostics keymaps
  map('n', '[d', vim.diagnostic.goto_prev, 'Previous Diagnostic')
  map('n', ']d', vim.diagnostic.goto_next, 'Next Diagnostic')
  map('n', '<leader>p', vim.diagnostic.open_float, 'Show Diagnostic Float')
  map('n', '<leader>P', vim.diagnostic.setloclist, 'Open Diagnostics List')

  if client:supports_method("textDocument/formatting") then
    vim.api.nvim_create_autocmd("BufWritePre", {
      group = vim.api.nvim_create_augroup("LspFormat." .. bufnr .. "." .. client.name, { clear = true }),
      buffer = bufnr,
      callback = function() vim.lsp.buf.format({ async = false, client_id = client.id }) end,
    })
  end
end

local lsp_capabilities
local cmp_nvim_lsp_ok, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
if not cmp_nvim_lsp_ok then
  vim.notify("cmp_nvim_lsp not found, using default LSP capabilities.", vim.log.levels.WARN)
  lsp_capabilities = vim.lsp.protocol.make_client_capabilities()
else
  lsp_capabilities = cmp_nvim_lsp.default_capabilities(vim.lsp.protocol.make_client_capabilities())
end
M.capabilities = lsp_capabilities

return M
