-- Env vars (incl conditional nvidia), monitors (per-host), input devices.
---@diagnostic disable: undefined-global

local gen = require("generated")

-- ---------------------------------------------------------------------------
-- Env vars
-- ---------------------------------------------------------------------------

if gen.has_nvidia then
  for _, e in ipairs({
    { "NVD_BACKEND",               "direct" },
    { "LIBVA_DRIVER_NAME",         "nvidia" },
    { "__GLX_VENDOR_LIBRARY_NAME", "nvidia" },
  }) do hl.env(e[1], e[2]) end
end

for _, e in ipairs({
  -- Cursor
  { "XCURSOR_SIZE",      "24" },
  { "HYPRCURSOR_SIZE",   "24" },
  { "XCURSOR_THEME",     "Bibata-Modern-Classic" },
  { "HYPRCURSOR_THEME",  "Bibata-Modern-Classic" },

  -- Force apps to Wayland
  { "GDK_BACKEND",                  "wayland" },
  { "QT_QPA_PLATFORM",              "wayland" },
  { "QT_STYLE_OVERRIDE",            "kvantum" },
  { "SDL_VIDEODRIVER",              "wayland,x11" },
  { "MOZ_ENABLE_WAYLAND",           "1" },
  { "ELECTRON_OZONE_PLATFORM_HINT", "wayland" },
  { "OZONE_PLATFORM",               "wayland" },

  -- Chromium: XCompose + all-Wayland
  { "CHROMIUM_FLAGS", "\"--enable-features=UseOzonePlatform --ozone-platform=wayland --gtk-version=4\"" },

  -- wofi: include nix-profile share dirs
  { "XDG_DATA_DIRS", "$XDG_DATA_DIRS:$HOME/.nix-profile/share:/nix/var/nix/profiles/default/share" },

  { "XCOMPOSEFILE", "~/.XCompose" },
  { "EDITOR",       "nvim" },
}) do hl.env(e[1], e[2]) end

-- ---------------------------------------------------------------------------
-- Monitors (per-host, from generated.monitors)
-- ---------------------------------------------------------------------------

for _, m in ipairs(gen.monitors) do
  hl.monitor(m)
end

-- ---------------------------------------------------------------------------
-- Headless outputs (per-host, from generated.headless_outputs)
--   Created on start, e.g. a deterministic output a remote streamer captures.
-- ---------------------------------------------------------------------------

if #gen.headless_outputs > 0 then
  hl.on("hyprland.start", function()
    for _, spec in ipairs(gen.headless_outputs) do
      hl.exec_cmd("hyprctl output create headless")
      hl.exec_cmd("hyprctl keyword monitor " .. spec)
    end
  end)
end

-- ---------------------------------------------------------------------------
-- Input devices
--   TODO: make host-specific via generated.devices if useful.
-- ---------------------------------------------------------------------------

for _, d in ipairs({
  { name = "tpps/2-elan-trackpoint",                          sensitivity = 0.0, accel_profile = "flat" },
  { name = "elecom-trackball-mouse-deft-pro-trackball-mouse", sensitivity = 0.1, accel_profile = "flat" },
}) do hl.device(d) end
