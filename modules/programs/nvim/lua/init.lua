-- Main entry point for custom Lua configuration.
-- Plugins are managed by vim.pack (Neovim 0.12+ builtin).

require('user_config.options')
require('user_config.keymaps')

-- Run post-install build steps for plugins that need them.
-- PackChanged fires after install/update/delete; defer so the plugin's
-- autoload paths are on rtp before we call into them.
vim.api.nvim_create_autocmd('PackChanged', {
  desc = 'Run build steps for plugins that need them',
  callback = function(ev)
    local data = ev.data
    if not data or data.kind == 'delete' then return end
    local name = data.spec and data.spec.name

    if name == 'telescope-fzf-native.nvim' and vim.fn.executable('make') == 1 then
      vim.system({ 'make' }, { cwd = data.path }):wait()
    elseif name == 'markdown-preview.nvim' then
      vim.schedule(function()
        vim.cmd.packadd('markdown-preview.nvim')
        vim.fn['mkdp#util#install']()
      end)
    end
  end,
})

-- Load plugins in dependency order. Each module calls vim.pack.add and setup.
local plugins = {
  'themes',            -- colorscheme first to avoid FOUC
  'treesitter',        -- required by aerial, render-markdown
  'one_liners',        -- nvim-web-devicons, mini.icons, fugitive, undotree
  'render-markdown',
  'tips',
  'aerial',
  'gitsigns',
  'vcsigns',
  'comment',
  'surround',
  'which-key',
  'lualine',
  'nvim-tree',
  'oil',
  'telescope',
  'language_features', -- lspconfig + cmp + LuaSnip + conform
  'neoscopes',
  'markdown-preview',
  'toggleterm',
  'kitty-scrollback',
}
for _, name in ipairs(plugins) do
  require('user_config.plugins.' .. name)
end
