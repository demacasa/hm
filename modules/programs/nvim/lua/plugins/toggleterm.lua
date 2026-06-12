vim.pack.add({
  { src = 'https://github.com/akinsho/toggleterm.nvim' },
})

require('toggleterm').setup({
  -- <C-\> toggles the default floating terminal (use case 1: quick popup)
  open_mapping = [[<c-\>]],
  direction = 'float',
  shade_terminals = true,
  shading_factor = 2,
  start_in_insert = true,
  persist_size = true,
  persist_mode = true,
  float_opts = {
    border = 'curved',
    winblend = 0,
  },
})

-- Terminal-mode escape hatches
vim.keymap.set('t', 'jk', [[<C-\><C-n>]], { desc = 'Exit terminal mode' })
vim.keymap.set('t', '<C-h>', [[<Cmd>wincmd h<CR>]], { desc = 'Window left' })
vim.keymap.set('t', '<C-j>', [[<Cmd>wincmd j<CR>]], { desc = 'Window down' })
vim.keymap.set('t', '<C-k>', [[<Cmd>wincmd k<CR>]], { desc = 'Window up' })
vim.keymap.set('t', '<C-l>', [[<Cmd>wincmd l<CR>]], { desc = 'Window right' })

-- Named, persistent terminals (use case 2: go-back-and-forth)
local Terminal = require('toggleterm.terminal').Terminal

local claude = Terminal:new({
  cmd = 'claude',
  hidden = true,
  direction = 'vertical',
  size = function() return math.floor(vim.o.columns * 0.4) end,
  on_open = function() vim.cmd('startinsert!') end,
})

local lazygit = Terminal:new({
  cmd = 'lazygit',
  hidden = true,
  direction = 'float',
  on_open = function() vim.cmd('startinsert!') end,
})

vim.keymap.set('n', "<leader>'c", function() claude:toggle() end, { desc = 'Toggle Claude terminal' })
vim.keymap.set('n', "<leader>'g", function() lazygit:toggle() end, { desc = 'Toggle Lazygit terminal' })
vim.keymap.set('n', "<leader>'h", '<Cmd>ToggleTerm direction=horizontal<CR>', { desc = 'Horizontal terminal' })
vim.keymap.set('n', "<leader>'v", '<Cmd>ToggleTerm direction=vertical<CR>', { desc = 'Vertical terminal' })
vim.keymap.set('n', "<leader>'f", '<Cmd>ToggleTerm direction=float<CR>', { desc = 'Floating terminal' })
