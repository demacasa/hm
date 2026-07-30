# Rust development support in the nvim module

Date: 2026-07-27
Status: approved

## Goal

Add Rust language support (LSP, diagnostics, formatting, treesitter highlighting)
to `modules/programs/nvim`, following the module's existing per-language pattern.

## Decisions

- **Toolchain is per-project, not global.** Only `rust-analyzer` is added to
  `home.packages`. Rust projects provide rustc/cargo/rustfmt/clippy via a flake
  devshell + direnv (the `hm.direnv` module already exists). Outside a devshell,
  rust-analyzer reports missing cargo but does not break nvim.
- **Plain LSP wiring, no rustaceanvim.** Rust uses the same
  `vim.lsp.config` + `vim.lsp.enable` flow as every other language here.
  nvim-lspconfig (already installed) supplies the base config (cmd, filetypes,
  root detection).
- **Clippy for save-time diagnostics.** The only non-default rust-analyzer
  setting is `check.command = "clippy"`, which runs the project's clippy
  instead of `cargo check`.
- **Format-on-save is inherited.** `base_config.on_attach` already installs a
  `BufWritePre` format autocmd for any server supporting
  `textDocument/formatting`; rust-analyzer does (it shells out to the project's
  rustfmt). No extra wiring.

## Changes

1. `modules/programs/nvim/nvim.nix` — add `rust-analyzer` to `home.packages`
   (keep-sorted block). The existing `cargo` entry (used by the nil LSP) is
   untouched.
2. `modules/programs/nvim/lua/lsp/rust_analyzer.lua` — new file:

   ```lua
   vim.lsp.config.rust_analyzer = {
     settings = {
       ['rust-analyzer'] = {
         check = { command = 'clippy' },
       },
     },
   }
   ```

3. `modules/programs/nvim/lua/lsp_completion_config.lua` — add
   `"rust_analyzer"` to the keep-sorted `servers` list.
4. `modules/programs/nvim/lua/plugins/treesitter.lua` — add `'rust'` to the
   keep-sorted parsers list.

## Error handling

Inherited from the existing loader: each `user_config.lsp.<server>` require is
`pcall`ed with a `vim.notify` on failure, and `vim.lsp.enable` on a machine
without a Rust project simply never attaches.

## Testing

`nix flake check` does not cover nvim lua; no new checks are added (out of
scope). Verification is a manual smoke test: open a `.rs` file in a project
with a devshell toolchain and confirm rust-analyzer attaches, clippy
diagnostics appear on save, and formatting runs on save.
