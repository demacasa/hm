" PICO-8 carts use Lua syntax. The treesitter Lua parser marks PICO-8
" shorthand (+=, ?, single-line if) as errors, so we use the regex Lua
" syntax. This syntax file must set syntax=lua after the ftplugin runs,
" because neovim's syntaxset autocmd resets syntax to the filetype name.
set syntax=lua
