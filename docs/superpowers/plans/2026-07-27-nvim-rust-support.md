# Nvim Rust Support Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add Rust language support (rust-analyzer LSP with clippy diagnostics, format-on-save, treesitter highlighting) to `modules/programs/nvim`.

**Architecture:** Follow the module's existing per-language pattern exactly: one package in `nvim.nix`, one `lua/lsp/<server>.lua` settings file, one entry in the `servers` list in `lsp_completion_config.lua`, one treesitter parser. Only `rust-analyzer` is shipped globally — the Rust toolchain (rustc/cargo/rustfmt/clippy) comes from each project's devshell via direnv.

**Tech Stack:** Nix (Home Manager module), Lua (Neovim 0.12, native `vim.lsp.config`/`vim.lsp.enable` + nvim-lspconfig base configs).

## Global Constraints

- Spec: `docs/superpowers/specs/2026-07-27-nvim-rust-support-design.md`.
- Do NOT add rustc, cargo, rustfmt, or clippy to `home.packages`. The existing `cargo` entry (used by the nil LSP) stays untouched.
- All list insertions go into existing `# keep-sorted start` / `-- keep-sorted start` blocks in alphabetical order.
- The only non-default rust-analyzer setting is `check.command = "clippy"`. No other settings, no new plugins (no rustaceanvim).
- This repo has no automated nvim tests; verification is `nix flake check -L` (catches Nix parse errors — the nvim module is imported, its config gated behind `mkIf`) plus a LuaJIT parse check of edited lua files.
- Work happens on the existing `nvim-rust-support` branch.

---

### Task 1: Ship rust-analyzer in nvim.nix

**Files:**
- Modify: `modules/programs/nvim/nvim.nix` (the `home.packages` keep-sorted block, lines ~26-40)

**Interfaces:**
- Consumes: nothing from other tasks.
- Produces: `rust-analyzer` binary on `$PATH` for the nvim environment; Task 2's `vim.lsp.enable("rust_analyzer")` relies on it.

- [ ] **Step 1: Add rust-analyzer to home.packages**

In `modules/programs/nvim/nvim.nix`, inside the `# keep-sorted start` block, add `rust-analyzer` between `pyright` and `tree-sitter`:

```nix
    home.packages = with pkgs; [
      # LSPs
      # keep-sorted start
      bash-language-server
      cargo # Used by nil LSP.
      go
      gopls
      lua-language-server
      nil
      nixpkgs-fmt
      prettierd
      pyright
      rust-analyzer
      tree-sitter
      typos-lsp
      # keep-sorted end
    ];
```

- [ ] **Step 2: Verify the flake still evaluates**

Run: `nix flake check -L`
Expected: all checks pass (this catches any Nix syntax error in `nvim.nix`, which is parsed when the module set is imported).

- [ ] **Step 3: Commit**

```bash
git add modules/programs/nvim/nvim.nix
git commit -m "feat(nvim): ship rust-analyzer"
```

---

### Task 2: Wire rust-analyzer and rust treesitter into the lua config

**Files:**
- Create: `modules/programs/nvim/lua/lsp/rust_analyzer.lua`
- Modify: `modules/programs/nvim/lua/lsp_completion_config.lua` (the `servers` keep-sorted list, lines ~13-21)
- Modify: `modules/programs/nvim/lua/plugins/treesitter.lua` (the `parsers` keep-sorted list, lines ~17-29)

**Interfaces:**
- Consumes: the `rust-analyzer` binary from Task 1; nvim-lspconfig's bundled `rust_analyzer` base config (cmd, filetypes, root markers); `user_config.lsp.base_config` (applied globally via `vim.lsp.config('*', …)` — do not reference it in the new file).
- Produces: LSP server name `"rust_analyzer"` enabled at startup; `rust` treesitter parser installed on first launch.

- [ ] **Step 1: Create the rust-analyzer settings file**

Create `modules/programs/nvim/lua/lsp/rust_analyzer.lua` with exactly:

```lua
vim.lsp.config.rust_analyzer = {
  settings = {
    ['rust-analyzer'] = {
      -- Project clippy (from the devshell toolchain) for save-time diagnostics
      -- instead of plain `cargo check`.
      check = { command = 'clippy' },
    },
  },
}
```

- [ ] **Step 2: Register the server in lsp_completion_config.lua**

In `modules/programs/nvim/lua/lsp_completion_config.lua`, add `"rust_analyzer"` to the keep-sorted `servers` list (after `"nil_ls"`, before `"typos_lsp"`):

```lua
local servers = {
  -- keep-sorted start
  "bashls",
  "gopls",
  "lua_ls",
  "nil_ls",
  "rust_analyzer",
  "typos_lsp",
  -- keep-sorted end
}
```

Leave the `table.insert(servers, "pyright")` line below the list untouched.

- [ ] **Step 3: Add the rust treesitter parser**

In `modules/programs/nvim/lua/plugins/treesitter.lua`, add `'rust'` to the keep-sorted `parsers` list (after `'python'`, before `'yaml'`):

```lua
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
  'rust',
  'yaml',
  -- keep-sorted end
}
```

- [ ] **Step 4: Parse-check the edited lua files**

Run:

```bash
nix shell nixpkgs#luajit -c sh -c '
  luajit -bl modules/programs/nvim/lua/lsp/rust_analyzer.lua /dev/null &&
  luajit -bl modules/programs/nvim/lua/lsp_completion_config.lua /dev/null &&
  luajit -bl modules/programs/nvim/lua/plugins/treesitter.lua /dev/null &&
  echo OK'
```

Expected: `OK` (luajit `-bl` compiles without executing; any syntax error fails the command).

- [ ] **Step 5: Verify the flake still evaluates**

Run: `nix flake check -L`
Expected: all checks pass.

- [ ] **Step 6: Commit**

```bash
git add modules/programs/nvim/lua/lsp/rust_analyzer.lua \
        modules/programs/nvim/lua/lsp_completion_config.lua \
        modules/programs/nvim/lua/plugins/treesitter.lua
git commit -m "feat(nvim): enable rust_analyzer LSP and rust treesitter parser"
```

---

## Manual smoke test (post-merge, on a real machine)

Not automatable in this repo: open a `.rs` file in a Rust project whose devshell provides the toolchain, confirm rust-analyzer attaches (`:LspInfo`), clippy diagnostics appear on save, and formatting runs on save. Outside a devshell, expect a missing-cargo error from rust-analyzer, not an nvim breakage.
