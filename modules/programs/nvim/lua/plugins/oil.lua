vim.pack.add({
  { src = 'https://github.com/stevearc/oil.nvim' },
})

require('oil').setup({
  view_options = {
    show_hidden = true,
  },
  default_file_explorer = false,
})

vim.keymap.set('n', '-', '<cmd>Oil<cr>', { desc = 'Open Oil' })
vim.keymap.set('n', '_', function()
  local oil = require('oil')
  oil.toggle_float(oil.get_current_dir())
end, { desc = 'Popup Open Oil' })
