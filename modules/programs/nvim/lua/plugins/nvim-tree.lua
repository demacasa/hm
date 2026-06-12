vim.pack.add({
  { src = 'https://github.com/nvim-tree/nvim-tree.lua' },
})

-- Disable netrw completely.
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

vim.opt.termguicolors = true

require('nvim-tree').setup({
  respect_buf_cwd = true,
  hijack_netrw = true,
  disable_netrw = true,

  update_focused_file = {
    enable = true,
    update_cwd = false,
  },
  renderer = {
    group_empty = true,
    highlight_git = true,
    icons = {
      show = {
        file = true,
        folder = true,
        folder_arrow = true,
        git = true,
      },
      -- Nerd-font glyphs are written as \u{...} escapes, not literal Private
      -- Use Area characters: literal PUA glyphs get silently stripped to ''
      -- by editors/tools that don't preserve them (this happened once during
      -- the lazy->vim.pack migration, blanking all the icons).
      glyphs = {
        default = '\u{e612}',
        symlink = '\u{f481}',
        folder = {
          arrow_closed = '\u{f460}',
          arrow_open = '\u{f47c}',
          default = '\u{e5ff}',
          open = '\u{e5fe}',
          empty = '\u{f114}',
          empty_open = '\u{f115}',
          symlink = '\u{f482}',
          symlink_open = '\u{f482}',
        },
        git = {
          unstaged = '✗',
          staged = '✓',
          unmerged = '\u{e727}',
          renamed = '➜',
          untracked = '★',
          deleted = '\u{f458}',
          ignored = '◌',
        },
      },
    },
  },
  view = {
    width = 30,
    side = 'left',
    preserve_window_proportions = true,
    number = true,
    relativenumber = true,
    signcolumn = 'yes',
    adaptive_size = true,
  },
  actions = {
    open_file = {
      quit_on_open = true,
      resize_window = true,
    },
  },
  git = {
    enable = true,
    ignore = false,
    timeout = 400,
  },
})
