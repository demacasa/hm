local ls = require("luasnip")

local s = ls.s            -- snippet
local i = ls.i            -- insert node
local t = ls.t            -- text node
local f = ls.f            -- function node
local d = ls.dynamic_node -- dynamic node

local function get_date()
  return { os.date("%Y-%m-%d") }
end

return {
  s("fm", {
    t("---"),
    t({ "", "title: " }), i(1, "Untitled Document"),
    t({ "", "date: " }), f(get_date, {}),
    t({ "", "publish: false" }),
    t({ "", "tags:" }),
    t({ "", "  - " }), i(2, "tag1"),
    t({ "", "---" }),
    t({ "", "" }),
    i(0), -- Final cursor position
  }),
}
