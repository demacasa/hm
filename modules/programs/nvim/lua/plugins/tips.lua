vim.pack.add({
  { src = 'https://github.com/MunifTanjim/nui.nvim' },
  { src = 'https://github.com/saxon1964/neovim-tips' },
})

require('neovim_tips').setup({
  user_file = vim.fn.stdpath('config') .. '/neovim_tips/user_tips.md',
  user_tip_prefix = '[User] ',
  warn_on_conflicts = true,
  daily_tip = 1,
})

local map = vim.keymap.set
map('n', '<leader>nto', ':NeovimTips<CR>', { desc = 'Neovim tips', noremap = true, silent = true })
map('n', '<leader>nte', ':NeovimTipsEdit<CR>', { desc = 'Edit your Neovim tips', noremap = true, silent = true })
map('n', '<leader>nta', ':NeovimTipsAdd<CR>', { desc = 'Add your Neovim tip', noremap = true, silent = true })
map('n', '<leader>nth', ':help neovim-tips<CR>', { desc = 'Neovim tips help', noremap = true, silent = true })
map('n', '<leader>ntr', ':NeovimTipsRandom<CR>', { desc = 'Show random tip', noremap = true, silent = true })
map('n', '<leader>ntp', ':NeovimTipsPdf<CR>', { desc = 'Open Neovim tips PDF', noremap = true, silent = true })
