vim.pack.add({
  { src = 'https://github.com/nvim-lua/plenary.nvim' },
  { src = 'https://github.com/lewis6991/gitsigns.nvim' },
})

require('gitsigns').setup({
  signs = {
    add          = { text = '┃' },
    change       = { text = '┃' },
    delete       = { text = '_' },
    topdelete    = { text = '‾' },
    changedelete = { text = '┃' },
    untracked    = { text = '┆' },
  },
  signcolumn = true,
  numhl      = false,
  linehl     = false,
  word_diff  = false,

  watch_gitdir = {
    follow_files = true,
  },
  attach_to_untracked = true,
  current_line_blame = false,
  current_line_blame_opts = {
    virt_text = true,
    virt_text_pos = 'eol',
    delay = 1000,
    ignore_whitespace = false,
  },
  current_line_blame_formatter = '<author>, <author_time:%R %Y-%m-%d> • <summary>',

  on_attach = function(bufnr)
    local gs = package.loaded.gitsigns

    local function map(mode, l, r, opts)
      opts = opts or {}
      opts.buffer = bufnr
      opts.silent = true
      if opts.desc then
        opts.desc = 'GitSigns: ' .. opts.desc
      end
      vim.keymap.set(mode, l, r, opts)
    end

    -- Navigation between hunks
    map('n', ']h', function() gs.next_hunk() end, { desc = 'Next Hunk' })
    map('n', '[h', function() gs.prev_hunk() end, { desc = 'Previous Hunk' })

    -- Actions for hunks
    map({ 'n', 'v' }, '<leader>hs', function() gs.stage_hunk() end, { desc = 'Stage Hunk' })
    map({ 'n', 'v' }, '<leader>hr', function() gs.reset_hunk() end, { desc = 'Reset Hunk' })
    map('n', '<leader>hS', gs.stage_buffer, { desc = 'Stage Buffer' })
    map('n', '<leader>hu', gs.undo_stage_hunk, { desc = 'Undo Stage Hunk (unstage last staged hunk)' })
    map('n', '<leader>hR', gs.reset_buffer, { desc = 'Reset Buffer (revert all changes)' })
    map('n', '<leader>hp', gs.preview_hunk, { desc = 'Preview Hunk' })

    -- Blame
    map('n', '<leader>hb', function() gs.blame_line({ full = true }) end, { desc = 'Blame Line (Full)' })
    map('n', '<leader>hB', function() gs.toggle_current_line_blame() end, { desc = 'Toggle Current Line Blame' })

    -- Diffing
    map('n', '<leader>hd', function() gs.diffthis('~') end, { desc = 'Diff This (~HEAD)' })
    map('n', '<leader>hD', function() gs.diffthis('@') end, { desc = 'Diff This (@INDEX)' })

    -- Text object for hunks
    map({ 'o', 'x' }, 'ih', ':<C-U>Gitsigns select_hunk<CR>', { desc = 'Select Hunk (Inner Hunk)' })
  end,
})
