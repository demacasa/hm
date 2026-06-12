-- Installed mainly so plugins that integrate with it (aerial, render-markdown,
-- telescope previewer) can pick up parsers. The `master` branch is archived
-- and incompatible with Neovim 0.12 (directives like `set-lang-from-info-string!`
-- crash with `attempt to call method 'range'` because the match table shape
-- changed). Use the `main` rewrite, which targets Neovim 0.12+.
-- Run :TSInstall <lang> to add languages.
vim.pack.add({
  {
    src = 'https://github.com/nvim-treesitter/nvim-treesitter',
    version = 'main',
  },
})

-- The `main` branch dropped `ensure_installed`; call the install API directly.
-- Filter to missing parsers so this is a no-op on subsequent startups.
local parsers = {
  -- keep-sorted start
  'bash',
  'go',
  'html',
  'lua',
  'markdown',
  'markdown_inline',
  'nix',
  'python',
  'yaml',
  -- keep-sorted end
}
local ts = require('nvim-treesitter')
local installed = ts.get_installed('parsers')
local missing = vim.tbl_filter(function(p)
  return not vim.tbl_contains(installed, p)
end, parsers)
if #missing > 0 then
  ts.install(missing)
end
