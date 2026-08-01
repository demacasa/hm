-- PICO-8 cart. The treesitter lua parser marks the PICO-8 shorthand
-- (+=, ?, single-line if) as errors, so use the regex lua syntax.
vim.bo.syntax = 'lua'

-- Sections other than __lua__ are machine-generated hex blobs; keep
-- long lines from wrapping into walls of text.
vim.wo.wrap = false

local function run_cart()
  if vim.fn.executable('pico8') == 0 then
    vim.notify('pico8 not found on PATH (see the PICO-8 packaging project)', vim.log.levels.ERROR)
    return
  end
  vim.cmd.write()
  local Terminal = require('toggleterm.terminal').Terminal
  Terminal:new({
    cmd = 'pico8 -run ' .. vim.fn.shellescape(vim.api.nvim_buf_get_name(0)),
    direction = 'horizontal',
    close_on_exit = false, -- keep printh output readable after exit
  }):toggle()
end

vim.keymap.set('n', '<leader>r', run_cart, { buffer = true, desc = 'Run cart in PICO-8' })
