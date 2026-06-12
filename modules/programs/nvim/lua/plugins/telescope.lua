local specs = {
  { src = 'https://github.com/nvim-lua/plenary.nvim' },
  -- Track `master`, not the `0.1.x` tag. The tagged release still calls the
  -- legacy `nvim-treesitter.parsers.ft_to_lang` API, which the nvim-treesitter
  -- `main` rewrite (see treesitter.lua) deleted — so previews crash with
  -- `attempt to call field 'ft_to_lang' (a nil value)`. `master` migrated the
  -- previewer to Neovim's builtin `vim.treesitter` API and works on 0.12+.
  { src = 'https://github.com/nvim-telescope/telescope.nvim', version = 'master' },
  { src = 'https://github.com/nvim-telescope/telescope-ui-select.nvim' },
  { src = 'https://github.com/debugloop/telescope-undo.nvim' },
}
if vim.fn.executable('make') == 1 then
  table.insert(specs, { src = 'https://github.com/nvim-telescope/telescope-fzf-native.nvim' })
end
vim.pack.add(specs)

local telescope = require('telescope')
local actions = require('telescope.actions')
local telescopeConfig = require('telescope.config')

-- Grab the default Telescope configuration
local vimgrep_arguments = { unpack(telescopeConfig.values.vimgrep_arguments) }

-- Search in hidden/dot files.
table.insert(vimgrep_arguments, '--hidden')
-- Exclude .git/
table.insert(vimgrep_arguments, '--glob')
table.insert(vimgrep_arguments, '!**/.git/*')

telescope.setup({
  defaults = {
    vimgrep_arguments = vimgrep_arguments,
    -- Nerd-font glyphs as \u{...} escapes (literal PUA chars get stripped).
    prompt_prefix = '\u{f002}  ',
    selection_caret = '\u{f061} ',
    layout_strategy = 'horizontal',
    layout_config = {
      horizontal = {
        prompt_position = 'top',
        preview_width = 0.55,
      },
      vertical = {
        mirror = false,
      },
      flex = {
        flip_columns = 120,
      },
    },
    sorting_strategy = 'ascending',
    winblend = 0,
    border = {},
    borderchars = { '─', '│', '─', '│', '╭', '╮', '╯', '╰' },
    mappings = {
      i = {
        ['<C-j>'] = actions.move_selection_next,
        ['<C-k>'] = actions.move_selection_previous,
        ['<C-q>'] = actions.send_to_qflist + actions.open_qflist,
        ['<esc>'] = actions.close,
        ['<CR>'] = actions.select_default + actions.center,
      },
      n = {
        ['<C-j>'] = actions.move_selection_next,
        ['<C-k>'] = actions.move_selection_previous,
        ['<C-q>'] = actions.send_to_qflist + actions.open_qflist,
        ['<esc>'] = actions.close,
      },
    },
    path_display = {
      'smart',
      'filename_first',
    },
  },
  pickers = {
    find_files = {
      theme = 'dropdown',
    },
    live_grep = {
      theme = 'dropdown',
    },
    buffers = {
      theme = 'dropdown',
      previewer = false,
      initial_mode = 'normal',
    },
    help_tags = {
      theme = 'dropdown',
    },
  },
  extensions = {
    fzf = {
      fuzzy = true,
      override_generic_sorter = true,
      override_file_sorter = true,
      case_mode = 'smart_case',
    },
    undo = {},
  },
})

pcall(telescope.load_extension, 'undo')
pcall(telescope.load_extension, 'fzf')
