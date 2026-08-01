# PICO-8 nvim Support Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add PICO-8 cart (`.p8`) editing to the nvim Home Manager module: pico8-ls LSP, Lua syntax highlighting, and a `<leader>r` run-cart keybinding.

**Architecture:** Follows the module's per-language pattern (see `rust_analyzer` precedent): a Nix package provides the server binary, `lua/lsp/<server>.lua` holds client config, the keep-sorted `servers` list enables it, and an ftplugin provides buffer-local behavior. The server binary is the esbuild-bundled `server/out-min/main.js` inside the nixpkgs VSCode extension `vscode-extensions.pollywoggames.pico8-ls`, wrapped as a `pico8-ls` executable (pico8-ls is not on npm; building from source needs nested network installs).

**Tech Stack:** Nix (Home Manager module), Lua (Neovim 0.12, `vim.lsp.config`/`vim.lsp.enable`), nvim-lspconfig (ships the `pico8_ls` base config), toggleterm.nvim.

**Spec:** `docs/superpowers/specs/2026-07-31-nvim-pico8-support-design.md`

## Global Constraints

- This repo uses **jj**, not git: commit with `jj commit -m "<msg>"` from the repo root. Conventional-commit prefixes (`feat:`, `docs:`).
- Lists between `# keep-sorted start` / `# keep-sorted end` (or `-- keep-sorted` in Lua) must stay alphabetically sorted.
- The PICO-8 runtime binary (`pico8`) is packaged in a separate project; assume it may be absent — never hard-fail on it.
- `.p8` carts only; do not attach pico8-ls to `.lua` files. `lua_ls` config must be untouched.
- No treesitter changes — no grammar exists for the PICO-8 dialect.
- Repo root: `/home/matthew/claude-workspaces/nvim-pico8`. Scratch dir for test files: use `$SCRATCH` = the session scratchpad, or any temp dir outside the repo.

---

### Task 1: pico8-ls package wrapper

**Files:**
- Create: `modules/programs/nvim/pico8-ls.nix`
- Modify: `modules/programs/nvim/nvim.nix` (the `home.packages` list, lines 26–42)

**Interfaces:**
- Consumes: `pkgs.vscode-extensions.pollywoggames.pico8-ls` (nixpkgs; unpacked extension at `$out/share/vscode/extensions/PollywogGames.pico8-ls/`, bundled server at `server/out-min/main.js` — verified present), `pkgs.nodejs`, `pkgs.writeShellScriptBin`.
- Produces: a `pico8-ls` executable on PATH accepting `--stdio` (what nvim-lspconfig's `pico8_ls` config invokes). Later tasks rely only on the binary name.

- [ ] **Step 1: Write the derivation**

Create `modules/programs/nvim/pico8-ls.nix`:

```nix
# pico8-ls is not published to npm; the nixpkgs VSCode extension ships a
# self-contained esbuild bundle of the server, so run that with node.
{ nodejs, vscode-extensions, writeShellScriptBin }:

writeShellScriptBin "pico8-ls" ''
  exec ${nodejs}/bin/node \
    ${vscode-extensions.pollywoggames.pico8-ls}/share/vscode/extensions/PollywogGames.pico8-ls/server/out-min/main.js \
    "$@"
''
```

- [ ] **Step 2: Build it standalone and verify it fails/succeeds honestly**

From the repo root:

```bash
nix build --impure --expr 'let f = builtins.getFlake (toString ./.); pkgs = import f.inputs.nixpkgs { system = builtins.currentSystem; }; in pkgs.callPackage ./modules/programs/nvim/pico8-ls.nix { }' -o "$SCRATCH/result-pico8-ls"
```

Expected: builds with no output errors; `$SCRATCH/result-pico8-ls/bin/pico8-ls` exists.

- [ ] **Step 3: LSP smoke test the binary**

```bash
printf 'Content-Length: 107\r\n\r\n{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"processId":null,"rootUri":null,"capabilities":{}}}' | timeout 10 "$SCRATCH/result-pico8-ls/bin/pico8-ls" --stdio 2>&1 | head -c 200
```

Expected output contains: `PICO-8 Language Server starting.` (server logs to the stream; an `initialize` response `Content-Length:` header may also appear. Either confirms the bundle runs.)

- [ ] **Step 4: Wire into home.packages**

In `modules/programs/nvim/nvim.nix`, the packages list currently reads:

```nix
    home.packages = with pkgs; [
      # LSPs
      # keep-sorted start
      bash-language-server
      ...
```

Add a callPackage entry **inside the keep-sorted block, sorted as written** (parenthesis sorts first, so it goes at the top of the block):

```nix
    home.packages = with pkgs; [
      # LSPs
      # keep-sorted start
      (callPackage ./pico8-ls.nix { })
      bash-language-server
      ...
```

- [ ] **Step 5: Run flake check**

```bash
nix flake check
```

Expected: `all checks passed!` (this evaluates and builds the Home Manager module, including the new package).

- [ ] **Step 6: Commit**

```bash
jj commit -m "feat(nvim): package pico8-ls language server"
```

---

### Task 2: LSP client wiring

**Files:**
- Create: `modules/programs/nvim/lua/lsp/pico8_ls.lua`
- Modify: `modules/programs/nvim/lua/lsp_completion_config.lua` (the `servers` list, lines 13–22)

**Interfaces:**
- Consumes: nvim-lspconfig's shipped `lsp/pico8_ls.lua` base config (`cmd = { 'pico8-ls', '--stdio' }`, `filetypes = { 'p8' }`, root = nearest dir containing a `*.p8`) — merged automatically by `vim.lsp.config`; the `pico8-ls` binary from Task 1.
- Produces: filetype `p8` for `*.p8` files (Task 3's ftplugin fires on this); server name `"pico8_ls"` enabled via the existing loader.

- [ ] **Step 1: Write a failing load test**

The deployed tree maps repo `lua/` → runtime `lua/user_config/`. Simulate that mapping and load the (not yet existing) module:

```bash
mkdir -p "$SCRATCH/rtp/lua"
ln -sfn /home/matthew/claude-workspaces/nvim-pico8/modules/programs/nvim/lua "$SCRATCH/rtp/lua/user_config"
nvim --headless --clean --cmd "set rtp+=$SCRATCH/rtp" \
  +"lua require('user_config.lsp.pico8_ls'); assert(vim.filetype.match({filename='x.p8'}) == 'p8', 'p8 filetype not detected')" \
  +q 2>&1
```

Expected: FAIL — `module 'user_config.lsp.pico8_ls' not found`.

- [ ] **Step 2: Create the config module**

Create `modules/programs/nvim/lua/lsp/pico8_ls.lua`:

```lua
-- Neovim has no built-in filetype detection for PICO-8 carts.
vim.filetype.add({ extension = { p8 = 'p8' } })

-- nvim-lspconfig's shipped pico8_ls defaults (cmd, filetypes, root) are
-- sufficient; nothing to override.
vim.lsp.config.pico8_ls = {}
```

- [ ] **Step 3: Re-run the load test, verify it passes**

Same command as Step 1. Expected: exits 0, no assertion error, no output.

- [ ] **Step 4: Register the server in the loader**

In `modules/programs/nvim/lua/lsp_completion_config.lua`, add `"pico8_ls"` to the keep-sorted list:

```lua
local servers = {
  -- keep-sorted start
  "bashls",
  "gopls",
  "lua_ls",
  "nil_ls",
  "pico8_ls",
  "rust_analyzer",
  "typos_lsp",
  -- keep-sorted end
}
```

(`"pico8_ls"` sorts between `"nil_ls"` and `"rust_analyzer"`.)

- [ ] **Step 5: Verify the loader still loads every server config**

```bash
nvim --headless --clean --cmd "set rtp+=$SCRATCH/rtp" \
  +"lua for _, s in ipairs({'bashls','gopls','lua_ls','nil_ls','pico8_ls','rust_analyzer','typos_lsp','pyright'}) do assert(pcall(require, 'user_config.lsp.' .. s), 'failed: ' .. s) end" \
  +q 2>&1
```

Expected: exits 0 with no output. (This mirrors the runtime loader's pcall loop without needing the full plugin set.)

- [ ] **Step 6: Commit**

```bash
jj commit -m "feat(nvim): enable pico8_ls LSP for .p8 carts"
```

---

### Task 3: Cart ftplugin — highlighting and run keybinding

**Files:**
- Create: `modules/programs/nvim/after/ftplugin/p8.lua`

**Interfaces:**
- Consumes: filetype `p8` (Task 2); `toggleterm.terminal` (installed plugin, see `lua/plugins/toggleterm.lua`); `pico8` binary on PATH (optional at runtime — packaged by a separate project).
- Produces: buffer-local `<leader>r` (leader is space) running `pico8 -run <cart>`; regex-Lua highlighting in cart buffers.

- [ ] **Step 1: Write a failing ftplugin test**

```bash
nvim --headless --clean --cmd "set rtp+=/home/matthew/claude-workspaces/nvim-pico8/modules/programs/nvim/after" \
  +"setfiletype p8" \
  +"lua assert(vim.bo.syntax == 'lua', 'syntax not lua: ' .. vim.bo.syntax); assert(vim.fn.maparg('<leader>r', 'n') ~= '', 'no <leader>r map')" \
  +q 2>&1
```

Expected: FAIL — `syntax not lua: p8` (the ftplugin doesn't exist yet, so nothing sets syntax).

Note: `--clean` skips our filetype detection, so the test triggers the FileType event directly with `:setfiletype p8`. toggleterm is absent under `--clean`; the ftplugin must therefore not `require` it at load time (only inside the keymap callback).

- [ ] **Step 2: Create the ftplugin**

Create `modules/programs/nvim/after/ftplugin/p8.lua`:

```lua
-- PICO-8 cart. The treesitter lua parser marks the PICO-8 shorthand
-- (+=, ?, single-line if) as errors, so use the regex lua syntax.
vim.bo.syntax = 'lua'

-- Sections other than __lua__ are machine-generated hex blobs; keep
-- long lines from wrapping into walls of text.
vim.wo.wrap = false

local function run_cart()
  if vim.fn.executable('pico8') == 0 then
    vim.notify('pico8 not found on PATH (see the PICO-8 packaging project)', vim.log.levels.ERROR)
    return
  end
  vim.cmd.write()
  local Terminal = require('toggleterm.terminal').Terminal
  Terminal:new({
    cmd = 'pico8 -run ' .. vim.fn.shellescape(vim.api.nvim_buf_get_name(0)),
    direction = 'horizontal',
    close_on_exit = false, -- keep printh output readable after exit
  }):toggle()
end

vim.keymap.set('n', '<leader>r', run_cart, { buffer = true, desc = 'Run cart in PICO-8' })
```

- [ ] **Step 3: Re-run the ftplugin test, verify it passes**

Same command as Step 1. Expected: exits 0, no output.

- [ ] **Step 4: Verify a non-p8 buffer is unaffected**

```bash
nvim --headless --clean --cmd "set rtp+=/home/matthew/claude-workspaces/nvim-pico8/modules/programs/nvim/after" \
  +"setfiletype lua" \
  +"lua assert(vim.fn.maparg('<leader>r', 'n') == '', '<leader>r leaked to non-p8 buffers')" \
  +q 2>&1
```

Expected: exits 0, no output.

- [ ] **Step 5: Commit**

```bash
jj commit -m "feat(nvim): p8 ftplugin with lua syntax and run-cart keybinding"
```

---

### Task 4: Final verification

**Files:** none (verification only).

**Interfaces:**
- Consumes: everything above.
- Produces: a pushed main branch, once verification passes.

- [ ] **Step 1: Full flake check**

From the repo root:

```bash
nix flake check
```

Expected: `all checks passed!`

- [ ] **Step 2: End-to-end headless check with a real cart**

```bash
mkdir -p "$SCRATCH/cartdir" && cat > "$SCRATCH/cartdir/hello.p8" <<'EOF'
pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
function _draw()
 cls()
 print("hello",44,60,7)
end
EOF
nvim --headless --clean \
  --cmd "set rtp+=$SCRATCH/rtp,/home/matthew/claude-workspaces/nvim-pico8/modules/programs/nvim/after" \
  +"lua require('user_config.lsp.pico8_ls')" \
  +"edit $SCRATCH/cartdir/hello.p8" \
  +"lua assert(vim.bo.filetype == 'p8', 'ft: ' .. vim.bo.filetype); assert(vim.bo.syntax == 'lua', 'syn: ' .. vim.bo.syntax)" \
  +q 2>&1
```

Expected: exits 0 — proves detection → filetype → ftplugin chain works on a real file. (LSP attach itself needs the deployed config with nvim-lspconfig; that is the manual smoke test below.)

- [ ] **Step 3: Report the manual smoke test checklist**

Deployment happens via the user's Home Manager switch on a consuming machine; it cannot run from this repo. Surface this checklist in the final summary rather than claiming these verified:

1. After `home-manager switch`, `pico8-ls --stdio` starts from a shell.
2. `nvim hello.p8`: `:LspInfo` shows pico8_ls attached; completing `circf` offers `circfill` with hover docs.
3. With PICO-8 installed: `<leader>r` opens a terminal split running the cart; `printh("x")` output appears there.

- [ ] **Step 4: Push to main**

```bash
jj bookmark move main --to @- && jj git push --bookmark main
```

Expected: push succeeds, main moves forward. (User has already approved pushing this feature's commits directly to main — spec was pushed the same way.)
