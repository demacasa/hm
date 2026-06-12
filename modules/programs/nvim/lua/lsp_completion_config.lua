--------------------------------------------------------------------
-- Base config
--------------------------------------------------------------------
local base_config = require('user_config.lsp.base_config')
vim.lsp.config('*', {
  capabilities = base_config.capabilities,
  on_attach = base_config.on_attach,
})

--------------------------------------------------------------------
-- Language-specific configurations
--------------------------------------------------------------------
local servers = {
  -- keep-sorted start
  "bashls",
  "gopls",
  "lua_ls",
  "nil_ls",
  "typos_lsp",
  -- keep-sorted end
}

table.insert(servers, "pyright")

-- Load server-specific configurations
for _, server_name in ipairs(servers) do
  local load_ok, _ = pcall(require, 'user_config.lsp.' .. server_name)
  if not load_ok then
    vim.notify("Failed to load LSP config for: " .. server_name, vim.log.levels.ERROR)
  end
end

-- Enable all servers
vim.lsp.enable(servers)

--------------------------------------------------------------------
-- Autocompletion (nvim-cmp) Setup
--------------------------------------------------------------------
local cmp_ok, cmp = pcall(require, "cmp")
if not cmp_ok then
  vim.notify("nvim-cmp not found! Autocompletion will not work.", vim.log.levels.ERROR)
  return -- Essential for completion
end

local luasnip_ok, luasnip = pcall(require, "luasnip")
if not luasnip_ok then
  vim.notify("LuaSnip not found! Snippet support will be limited.", vim.log.levels.WARN)
end

cmp.setup({
  snippet = {
    expand = function(args)
      if luasnip_ok then
        luasnip.lsp_expand(args.body)
      end
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.abort(),
    ['<CR>'] = cmp.mapping.confirm({ behavior = cmp.ConfirmBehavior.Insert, select = false }),
    ['<Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip_ok and luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      else
        fallback()
      end
    end, { "i", "s" }),
    ['<S-Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip_ok and luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { "i", "s" }),
  }),
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
    { name = 'buffer' },
    { name = 'path' },
  }),
  formatting = {
    format = function(entry, vim_item)
      -- Icons: Ensure nvim-web-devicons is installed and user_config/icons.lua exists
      local icons_ok, icons_config = pcall(require, 'user_config.icons')
      if icons_ok and icons_config and icons_config.lsp_kind then
        vim_item.kind = string.format('%s %s', icons_config.lsp_kind[vim_item.kind] or '?', vim_item.kind)
      else
        vim_item.kind = vim_item.kind -- Show kind without icon if icons config not found
      end

      vim_item.menu = ({
        buffer   = "[Buffer]",
        nvim_lsp = "[LSP]",
        luasnip  = "[Snippet]",
        path     = "[Path]",
      })[entry.source.name]
      return vim_item
    end
  },
  window = {
    completion = cmp.config.window.bordered(),
    documentation = cmp.config.window.bordered(),
  },
  experimental = {
    ghost_text = true, -- Requires Neovim 0.10+
  }
})

-- Command line completion
cmp.setup.cmdline('/', {
  mapping = cmp.mapping.preset.cmdline(),
  sources = {
    { name = 'buffer' }
  }
})

cmp.setup.cmdline(':', {
  mapping = cmp.mapping.preset.cmdline(),
  sources = cmp.config.sources({
    { name = 'path' }
  }, {
    { name = 'cmdline' }
  })
})
