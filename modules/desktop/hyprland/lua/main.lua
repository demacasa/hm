-- Hyprland config — handwritten lua.
-- Entry point loaded via Home Manager's `extraConfig = "require('main')"`.
-- Per-host data (monitors, theme colors, quick-apps, wallpaper, nvidia flag)
-- comes from `generated.lua`, written by Nix from hostSpec/stylix.
-- Per-host overrides go in `local.lua` (loaded last, optional).
--
-- Module map:
--   look.lua    — curves, animations, hl.config
--   system.lua  — env vars (incl conditional nvidia), monitors, devices
--   windows.lua — window_rule + layer_rule
--   binds.lua   — all hl.bind calls (quick-apps loop, workspace loop, etc.)
--
-- The `hl` global is injected by Hyprland's lua runtime. Its types live in
-- ${cfg.finalPackage}/share/hypr/stubs/hl.meta.lua but aren't in scope when
-- editing from this repo; the checks/hyprland-luals.nix derivation runs luals
-- with the real stubs.
---@diagnostic disable: undefined-global

local gen = require("generated")

require("look")
require("system")
require("windows")
require("binds")

-- ---------------------------------------------------------------------------
-- Autostart
-- ---------------------------------------------------------------------------

hl.on("hyprland.start", function()
  hl.exec_cmd("systemctl --user start hyprpolkitagent")
  hl.exec_cmd("wl-clip-persist --clipboard regular")
  hl.exec_cmd("clipse -listen")
  hl.exec_cmd("pkill -w waybar || true; waybar &")
end)

-- Wallpaper (path from generated, theme-driven)
hl.on("hyprland.start", function()
  hl.exec_cmd("awww-daemon")
  hl.exec_cmd("awww img " .. gen.theme.wallpaper_path)
end)

-- ---------------------------------------------------------------------------
-- Per-host overrides (optional)
-- ---------------------------------------------------------------------------

-- Hyprland's require writes to stderr (which --verify-config treats as a
-- failure) even when wrapped in pcall, so probe package.path first.
if package.searchpath("local", package.path) then
  require("local")
end
