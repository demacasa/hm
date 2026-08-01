# PICO-8 development support in the nvim module

Date: 2026-07-31
Status: approved

## Goal

Add PICO-8 cartridge (`.p8`) editing support to `modules/programs/nvim`:
LSP (completion, hover, goto-definition for the PICO-8 API), Lua-based
syntax highlighting, and a keybinding to run the current cart in PICO-8.

## Decisions

- **pico8-ls is the language server.** The PICO-8 Lua dialect (`+=`, `!=`,
  `?` print shorthand, single-line `if`) breaks `lua_ls`, so carts get the
  dedicated community server [pico8-ls](https://github.com/japhib/pico8-ls).
  nvim-lspconfig (already installed) ships a `pico8_ls` config with the
  right cmd, filetype, and root detection — no overrides needed.
- **pico8-ls comes from the nixpkgs VSCode extension.** pico8-ls is not
  published to npm and its repo needs nested, network-dependent installs,
  so building it from source in Nix is disproportionately messy. Instead,
  `vscode-extensions.pollywoggames.pico8-ls` (already in nixpkgs, tracks
  upstream releases) ships the esbuild-bundled, dependency-free server at
  `server/out-min/main.js`; a `writeShellScriptBin` wrapper runs it with
  Node as `pico8-ls`. Verified: the bundled server answers LSP
  `initialize` under plain `node`.
- **`.p8` carts only.** pico8-ls attaches to filetype `p8` exclusively;
  the `#include`-separate-`.lua`-files workflow is out of scope and can be
  layered on later. `lua_ls` and the rest of the setup are untouched.
- **Regex Lua syntax for highlighting, no treesitter.** No treesitter
  grammar exists for the dialect, and the standard Lua parser marks the
  PICO-8 shorthand as errors. The regex Lua syntax tolerates it, so cart
  buffers set `syntax = lua`. The parsers list stays unchanged.
- **The PICO-8 binary is assumed on PATH.** Packaging PICO-8 (proprietary)
  is a separate ongoing project. The run keybinding guards on
  `executable('pico8')` and notifies if it is missing.

## Changes

1. `modules/programs/nvim/pico8-ls.nix` — new file: a
   `writeShellScriptBin "pico8-ls"` wrapper that execs
   `${nodejs}/bin/node` on the bundled server inside
   `vscode-extensions.pollywoggames.pico8-ls`. Exposes the `pico8-ls`
   binary.
2. `modules/programs/nvim/nvim.nix` — add
   `(pkgs.callPackage ./pico8-ls.nix { })` to `home.packages`.
3. `modules/programs/nvim/lua/lsp/pico8_ls.lua` — new file:

   ```lua
   -- Neovim has no built-in detection for PICO-8 carts.
   vim.filetype.add({ extension = { p8 = 'p8' } })

   -- nvim-lspconfig's shipped defaults are sufficient.
   vim.lsp.config.pico8_ls = {}
   ```

4. `modules/programs/nvim/lua/lsp_completion_config.lua` — add
   `"pico8_ls"` to the keep-sorted `servers` list.
5. `modules/programs/nvim/after/ftplugin/p8.lua` — new file:
   - `vim.bo.syntax = 'lua'` for highlighting.
   - Buffer-local `<leader>r`: write the buffer, then open a toggleterm
     `Terminal` (the named-terminal pattern from `plugins/toggleterm.lua`)
     running `pico8 -run <absolute cart path>`, so `printh` output is
     visible. If `executable('pico8') == 0`, `vim.notify` an error
     instead of launching.

## Error handling

Inherited from the existing loader: each `user_config.lsp.<server>`
require is `pcall`ed with a `vim.notify` on failure, and
`vim.lsp.enable` on a machine with no carts simply never attaches. The
run keymap fails soft with a notification when PICO-8 is not installed.

## Testing

`nix build` of the new derivation verifies packaging (and `nix flake
check` keeps evaluating the module). nvim-side verification is a manual
smoke test: open a `.p8` cart, confirm pico8-ls attaches and completes
API built-ins (e.g. `circfill`), confirm highlighting renders, and
confirm `<leader>r` launches the cart in PICO-8 with `printh` output in
the terminal.
