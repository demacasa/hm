-- hl.window_rule and hl.layer_rule definitions.
-- Hyprland evaluates window rules in declaration order; ipairs preserves it.
---@diagnostic disable: undefined-global

for _, r in ipairs({
  -- General behavior
  { match = { class = ".*" }, suppress_event = "maximize" },
  { match = { class = ".*" }, opacity = "0.97 0.9"        },

  -- Browser / web apps
  { match = { class = "^(chromium)$" },                                     tile = true       },
  { match = { class = "^(google-chrome-stable)$", title = ".*Youtube.*" },  opacity = "1 1"   },
  { match = { class = "^(google-chrome-stable)$" },                         opacity = "1 0.97"},
  { match = { initial_class = "^(chrome-.*-Default)$" },                    opacity = "0.97 0.9" },
  { match = { initial_class = "^(chrome-youtube.*-Default)$" },             opacity = "1 1"   },

  -- Floating windows
  { match = { class = "^(org.pulseaudio.pavucontrol|blueberry.py)$" },      float = true },
  { match = { class = "^(steam)$", title = "^(Steam)$" },                   float = true },

  -- OpenGL viewports break with non-1.0 opacity
  { match = { class = "^(steam|vlc|org\\.freecad\\.FreeCAD)$" }, opacity = "1 1" },

  -- Steam Big Picture: maximize on workspace 10 (background launcher)
  { match = { class = "^(steam)$", title = "^(Steam Big Picture Mode)$" }, fullscreen = true },
  { match = { class = "^(steam)$", title = "^(Steam Big Picture Mode)$" }, workspace  = "10" },

  -- Gamescope (game window): fullscreen on workspace 9, no opacity, immediate
  { match = { class = "^(gamescope)$" }, fullscreen = true },
  { match = { class = "^(gamescope)$" }, workspace  = "9"  },
  { match = { class = "^(gamescope)$" }, opacity    = "1 1"},
  { match = { class = "^(gamescope)$" }, immediate  = true },

  -- RetroArch
  { match = { class = "^(com.libretro.RetroArch)$" }, fullscreen = true },

  -- Steam games (fullscreen, immediate, opacity 1 = direct scanout, workspace 9)
  { match = { class = "^(steam_app_.*)$" }, fullscreen = true  },
  { match = { class = "^(steam_app_.*)$" }, immediate  = true  },
  { match = { class = "^(steam_app_.*)$" }, opacity    = "1 1" },
  { match = { class = "^(steam_app_.*)$" }, workspace  = "9"   },

  -- XWayland ghost-window fix
  {
    match = { class = "^$", title = "^$", xwayland = true, float = true, fullscreen = false, pin = false },
    no_focus = true,
  },

  -- Clipboard manager
  {
    match = { class = "(clipse)" },
    float = true, size = "782 652", stay_focused = true,
  },

  -- Class → workspace
  { match = { class = "^(tmux)$" },                                   workspace = "1"  },
  { match = { class = "^(google-chrome)$" },                          workspace = "2"  },
  { match = { class = "^(chrome-gemini\\.google\\.com__-Default)$" }, workspace = "3"  },
  { match = { class = "^(yazi)$" },                                   workspace = "4"  },
  { match = { class = "^(btop)$" },                                   workspace = "5"  },
  { match = { class = "^(notes)$" },                                  workspace = "10" },
}) do hl.window_rule(r) end

-- Layer rules
for _, r in ipairs({
  { match = { namespace = "wofi" }, blur = true },
}) do hl.layer_rule(r) end
