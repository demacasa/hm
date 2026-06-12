vim.pack.add({
  { src = 'https://github.com/mikesmithgh/kitty-scrollback.nvim' },
})

-- The kitty side (action_alias + maps) is wired up in kitty.nix, pointing at
-- the python kitten inside this same vim.pack checkout so the lua and kitten
-- versions can never drift.
require('kitty-scrollback').setup()
