--------------------------------------------------------------------
-- LSP and Autocompletion (nvim-cmp)
--------------------------------------------------------------------

vim.pack.add({
  { src = 'https://github.com/neovim/nvim-lspconfig' },
  { src = 'https://github.com/rafamadriz/friendly-snippets' },
  { src = 'https://github.com/L3MON4D3/LuaSnip' },
  { src = 'https://github.com/saadparwaiz1/cmp_luasnip' },
  { src = 'https://github.com/hrsh7th/cmp-nvim-lsp' },
  { src = 'https://github.com/hrsh7th/cmp-buffer' },
  { src = 'https://github.com/hrsh7th/cmp-path' },
  { src = 'https://github.com/hrsh7th/cmp-cmdline' },
  { src = 'https://github.com/hrsh7th/nvim-cmp' },
  { src = 'https://github.com/stevearc/conform.nvim' },
})

-- LuaSnip
require('luasnip').filetype_extend('markdown_inline', { 'markdown' })
require('luasnip.loaders.from_lua').load({
  paths = { '~/.config/nvim/lua/user_config/snippets' },
})
require('luasnip.loaders.from_vscode').lazy_load()

-- nvim-cmp + LSP wiring
require('user_config.lsp_completion_config')

-- conform.nvim
require('conform').setup({
  formatters_by_ft = {
    markdown = { 'prettierd' },
  },
})
