vim.pack.add({
  { src = 'https://github.com/nvim-lualine/lualine.nvim' },
})

require('lualine').setup({
  options = {
    -- catppuccin-nvim is the auto-flavour theme provided by catppuccin/nvim;
    -- it picks up vim.g.catppuccin_flavour set in themes.lua.
    theme = 'catppuccin-nvim',
    icons_enabled = true,
    -- Powerline glyphs as \u{...} escapes (literal PUA chars get stripped).
    component_separators = { left = '\u{e0b1}', right = '\u{e0b3}' },
    section_separators = { left = '\u{e0b0}', right = '\u{e0b2}' },
    disabled_filetypes = {
      statusline = {},
      winbar = {},
    },
    ignore_focus = {},
    always_divide_middle = true,
    globalstatus = false,
  },
  sections = {
    lualine_a = { 'mode' },
    lualine_b = { 'branch', 'diff', 'diagnostics' },
    lualine_c = { { 'filename', path = 1, shorting_rule = 'relative' } },
    lualine_x = { 'encoding', 'fileformat', 'filetype' },
    lualine_y = { 'progress' },
    lualine_z = { 'location' },
  },
  inactive_sections = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = { { 'filename', path = 1, shorting_rule = 'relative' } },
    lualine_x = { 'location' },
    lualine_y = {},
    lualine_z = {},
  },
  tabline = {},
  winbar = {},
  inactive_winbar = {},
  extensions = { 'nvim-tree', 'fugitive', 'quickfix' },
})
