-- PICO-8 cart. The treesitter lua parser marks the PICO-8 shorthand
-- (+=, ?, single-line if) as errors, so use the regex lua syntax.
-- Syntax is set by after/syntax/p8.vim (ftplugin assignment is clobbered
-- by neovim's syntaxset autocmd before the syntax file re-asserts lua).

-- Sections other than __lua__ are machine-generated hex blobs; keep
-- long lines from wrapping into walls of text.
vim.wo.wrap = false

-- One cached toggleterm Terminal per cart buffer, keyed by bufnr, so
-- re-running a cart reuses/replaces the same terminal instead of
-- stacking a new horizontal split on every press.
local terminals = {}

local function run_cart()
  if vim.fn.executable('pico8') == 0 then
    vim.notify('pico8 not found on PATH (see the PICO-8 packaging project)', vim.log.levels.ERROR)
    return
  end
  vim.cmd.update()
  local bufnr = vim.api.nvim_get_current_buf()
  local existing = terminals[bufnr]
  if existing then
    existing:shutdown()
  end
  local Terminal = require('toggleterm.terminal').Terminal
  local term = Terminal:new({
    cmd = 'pico8 -run ' .. vim.fn.shellescape(vim.api.nvim_buf_get_name(0)),
    direction = 'horizontal',
    close_on_exit = false, -- keep printh output readable after exit
  })
  terminals[bufnr] = term
  term:toggle()
end

vim.keymap.set('n', '<leader>r', run_cart, { buffer = true, desc = 'Run cart in PICO-8' })
