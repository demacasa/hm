local ls = require("luasnip")

local s = ls.s            -- snippet
local i = ls.i            -- insert node
local t = ls.t            -- text node
local f = ls.f            -- function node
local d = ls.dynamic_node -- dynamic node

return {
  s("module", {
    t("{ ... }:"),
    t({ "{", }),
    i(0), -- Final cursor position
    t({ "}", }),
  }),
}
