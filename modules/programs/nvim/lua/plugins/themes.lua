vim.pack.add({
  { src = 'https://github.com/catppuccin/nvim', name = 'catppuccin' },
})

vim.g.catppuccin_flavour = 'mocha' -- latte, frappe, macchiato, mocha
require('catppuccin').setup({
  flavour = vim.g.catppuccin_flavour,
  transparent_background = true,
  term_colors = true,
  integrations = {
    gitsigns = true,
  },
})
vim.cmd.colorscheme('catppuccin')
