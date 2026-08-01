-- Neovim has no built-in filetype detection for PICO-8 carts.
vim.filetype.add({ extension = { p8 = 'p8' } })

-- nvim-lspconfig's shipped pico8_ls defaults (cmd, filetypes, root) are
-- sufficient; nothing to override.
vim.lsp.config.pico8_ls = {}
