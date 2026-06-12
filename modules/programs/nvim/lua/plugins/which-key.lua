vim.pack.add({
  { src = 'https://github.com/folke/which-key.nvim' },
})

require('which-key').setup({
  plugins = {
    marks = true,
    registers = true,
    spelling = {
      enabled = true,
      suggestions = 20,
    },
    presets = {
      operators = true,
      motions = true,
      text_objects = true,
      windows = true,
      nav = true,
      z = true,
      g = true,
    },
  },
  icons = {
    -- Nerd-font glyphs as \u{...} escapes (literal PUA chars get stripped).
    keys = {
      ['<space>'] = '\u{f1050}',
      ['telescope'] = '\u{e209} ',
      ['Telescope'] = '\u{e209} ',
      ['operator'] = '\u{eb64}',
    },
  },
})

vim.keymap.set('n', '<leader>?', function()
  require('which-key').show({ global = false })
end, { desc = 'Buffer Local Keymaps (which-key)' })
