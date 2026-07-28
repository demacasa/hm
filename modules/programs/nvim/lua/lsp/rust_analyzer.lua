vim.lsp.config.rust_analyzer = {
  settings = {
    ['rust-analyzer'] = {
      -- Project clippy (from the devshell toolchain) for save-time diagnostics
      -- instead of plain `cargo check`.
      check = { command = 'clippy' },
    },
  },
}
