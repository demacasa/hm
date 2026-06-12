local opt = vim.opt

-- Global options
opt.mouse = 'a'               -- Enable mouse support in all modes
opt.clipboard = 'unnamedplus' -- System clipboard
opt.swapfile = false          -- Don't use swap files
opt.undofile = true           -- Enable persistent undo

-- UI
opt.number = true         -- Show line numbers
opt.relativenumber = true -- Show relative line numbers
opt.showmatch = true      -- Highlight matching parentheses
opt.foldmethod = 'marker' -- Enable folding (e.g., with {{{ ... }}})
opt.splitright = true     -- When splitting vertically, new window goes to right
opt.splitbelow = true     -- When splitting horizontally, new window goes to bottom
opt.termguicolors = true  -- Enable 24-bit RGB colors
opt.cursorline = true     -- Highlight current line
opt.scrolloff = 5         -- Keep N lines above or below cursor

-- Searching
opt.hlsearch = true
opt.incsearch = true
opt.ignorecase = true
opt.smartcase = true

-- Tabs & Indentation
opt.tabstop = 2      -- Number of spaces a <Tab> in the file counts for
opt.shiftwidth = 2   -- Number of spaces to use for each step of (auto)indent
opt.expandtab = true -- Use spaces instead of tabs
opt.autoindent = true

vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
  pattern = "*.justfile",
  callback = function()
    vim.bo.filetype = "just"
  end,
})
