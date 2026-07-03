-- Curves, animations, hl.config block.
---@diagnostic disable: undefined-global

local gen = require("generated")

-- ---------------------------------------------------------------------------
-- Curves
-- ---------------------------------------------------------------------------

for _, c in ipairs({
  { "easeOutQuint",   { type = "bezier", points = { { 0.23, 1 }, { 0.32, 1 } } } },
  { "easeInOutCubic", { type = "bezier", points = { { 0.65, 0.05 }, { 0.36, 1 } } } },
  { "linear",         { type = "bezier", points = { { 0, 0 }, { 1, 1 } } } },
  { "almostLinear",   { type = "bezier", points = { { 0.5, 0.5 }, { 0.75, 1 } } } },
  { "quick",          { type = "bezier", points = { { 0.15, 0 }, { 0.1, 1 } } } },
}) do hl.curve(c[1], c[2]) end

-- ---------------------------------------------------------------------------
-- Animations
-- ---------------------------------------------------------------------------

for _, a in ipairs({
  { leaf = "global",        enabled = true,  speed = 10,   bezier = "default" },
  { leaf = "border",        enabled = true,  speed = 5.39, bezier = "easeOutQuint" },
  { leaf = "windows",       enabled = true,  speed = 4.79, bezier = "easeOutQuint" },
  { leaf = "windowsIn",     enabled = true,  speed = 4.1,  bezier = "easeOutQuint", style = "gnomed" },
  { leaf = "windowsOut",    enabled = true,  speed = 1.49, bezier = "linear",       style = "popin 87%" },
  { leaf = "fadeIn",        enabled = true,  speed = 1.73, bezier = "almostLinear" },
  { leaf = "fadeOut",       enabled = true,  speed = 1.46, bezier = "almostLinear" },
  { leaf = "fade",          enabled = true,  speed = 3.03, bezier = "quick" },
  { leaf = "layers",        enabled = true,  speed = 3.81, bezier = "easeOutQuint" },
  { leaf = "layersIn",      enabled = true,  speed = 4,    bezier = "easeOutQuint", style = "fade" },
  { leaf = "layersOut",     enabled = true,  speed = 1.5,  bezier = "linear",       style = "fade" },
  { leaf = "fadeLayersIn",  enabled = true,  speed = 1.79, bezier = "almostLinear" },
  { leaf = "fadeLayersOut", enabled = true,  speed = 1.39, bezier = "almostLinear" },
  { leaf = "workspaces",    enabled = false, speed = 0,    bezier = "ease" },
}) do hl.animation(a) end

-- ---------------------------------------------------------------------------
-- Config (general / decoration / dwindle / input / misc / xwayland)
-- ---------------------------------------------------------------------------

hl.config({
  general = {
    gaps_in                 = 5,
    gaps_out                = 10,

    border_size             = 2,
    ["col.active_border"]   = gen.theme.active_border,
    ["col.inactive_border"] = gen.theme.inactive_border,

    resize_on_border        = false,
    allow_tearing           = true,
    layout                  = "dwindle",
  },

  decoration = {
    rounding = 4,
    shadow   = { enabled = true, range = 14, render_power = 3, color = "rgba(00000045)" },
    blur     = { enabled = true, size = 3, passes = 1, vibrancy = 0.1696 },
  },

  animations = { enabled = true },

  dwindle = {
    preserve_split = true,
    force_split    = 2,
  },

  master = { new_status = "master" },

  input = {
    kb_layout    = "us",
    kb_options   = "compose:caps",
    follow_mouse = 2,
    sensitivity  = 0,
    touchpad     = { natural_scroll = false },
  },

  misc = {
    disable_hyprland_logo    = true,
    disable_splash_rendering = true,
  },

  xwayland = { force_zero_scaling = true },

  ecosystem = { no_update_news = true },
})
