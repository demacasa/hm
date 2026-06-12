-- Custom keymappings

local map = vim.keymap.set

-- Remap Space as leader key
-- This needs to be done before other mappings use <leader>
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- jk for Escape in insert mode
map('i', 'jk', '<Esc>', { noremap = true, silent = true })
map('i', 'JK', '<Esc>', { noremap = true, silent = true })

map('n', '<leader><leader>x', '<cmd>source %<CR>', { desc = 'Execute the current file' })

map('n', '<leader>w', '<cmd>wall<CR>', { desc = 'Save all' })
--------------------------------------------------------------------
-- Window Navigation
--------------------------------------------------------------------
map('n', ',w', '<C-w>w', { desc = 'Focus next window', silent = true })

--------------------------------------------------------------------
-- Telescope Keymaps
--------------------------------------------------------------------
map('n', '<leader>ss', function() require('neoscopes').select() end, { desc = '[S]cope [s]elect' })
map('n', '<leader>ff', function()
  require('telescope.builtin').find_files({
    search_dirs = require("neoscopes").get_current_dirs(),
  })
end, { desc = '[F]ind [F]iles' })
map('n', '<leader>fg', function()
  require('telescope.builtin').live_grep({
    search_dirs = require("neoscopes").get_current_dirs(),
  })
end, { desc = '[F]ind [G]rep' })
map('n', '<leader>fb', function() require('telescope.builtin').buffers() end, { desc = 'Find Buffers' })
map('n', '<leader>fh', function() require('telescope.builtin').help_tags() end, { desc = 'Help Tags' })
map('n', '<leader>fo', function() require('telescope.builtin').oldfiles() end, { desc = 'Find Old Files (History)' })
map('n', '<leader>fz', function() require('telescope.builtin').current_buffer_fuzzy_find() end,
  { desc = 'Fuzzy Find in Current Buffer' })
map('n', '<leader>fr', function() require('telescope.builtin').resume() end, { desc = 'Resume' })
-- Git specific (if you want them and have git integration)
map('n', '<leader>gf', function() require('telescope.builtin').git_files() end, { desc = 'Git Files (current branch)' })
map('n', '<leader>gc', function() require('telescope.builtin').git_commits() end, { desc = 'Git Commits' })
map('n', '<leader>gs', function() require('telescope.builtin').git_status() end, { desc = 'Git Status' })

map('n', '<leader>u', '<cmd>Telescope undo<cr>', { desc = 'Undo Tree' })

--------------------------------------------------------------------
-- Nvim-Tree Keymaps
--------------------------------------------------------------------
-- Toggle NvimTree
map('n', '<leader>t', '<Cmd>NvimTreeToggle<CR>', { desc = 'Toggle NvimTree' })
-- Focus if open, or open and focus
map('n', '<leader>T', '<Cmd>NvimTreeFocus<CR>', { desc = 'Focus NvimTree' })
map('n', ',t', '<Cmd>NvimTreeFindFile<CR>', { desc = 'NvimTree Find File (focus on current file)' })

--------------------------------------------------------------------
-- Aerial Overview Keymaps
--------------------------------------------------------------------
map('n', '<leader>o', '<cmd>AerialToggle!<CR>')
