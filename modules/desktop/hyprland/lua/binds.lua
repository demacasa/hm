-- All hl.bind definitions: quick-app launchers (from generated.quick_apps),
-- workspace + direction loops, session controls, tiling, screenshots,
-- mouse, multimedia.
---@diagnostic disable: undefined-global

local gen = require("generated")

-- Quick-app launchers (per-host, from generated.quick_apps)
for _, a in ipairs(gen.quick_apps) do
  hl.bind(a.keys, hl.dsp.exec_cmd(a.command), { description = a.description })
end

-- Workspace switch + move-to (SUPER {1..0} / SUPER SHIFT {1..0})
for i = 1, 10 do
  local key = (i == 10) and "0" or tostring(i)
  hl.bind("SUPER + " .. key,         hl.dsp.focus({workspace = i}),       { description = "Focus workspace " .. i })
  hl.bind("SUPER + SHIFT + " .. key, hl.dsp.window.move({workspace = i}), { description = "Move window to workspace " .. i })
end

-- Direction binds (focus + swap)
for _, dir in ipairs({ "left", "right", "up", "down" }) do
  hl.bind("SUPER + " .. dir,         hl.dsp.focus({direction = dir}),       { description = "Focus window " .. dir })
  hl.bind("SUPER + SHIFT + " .. dir, hl.dsp.window.swap({direction = dir}), { description = "Swap window " .. dir })
end

-- Session / launchers
hl.bind("SUPER + space",              hl.dsp.exec_cmd("wofi --show drun --sort-order=alphabetical"), { description = "App launcher (wofi)" })
hl.bind("SUPER + SHIFT + SPACE",      hl.dsp.exec_cmd("pkill -SIGUSR1 waybar"),                      { description = "Reload waybar" })
hl.bind("SUPER + W",                  hl.dsp.window.close(),                                         { description = "Close active window" })
hl.bind("SUPER + ESCAPE",             hl.dsp.exec_cmd("hyprlock"),                                   { description = "Lock screen" })
hl.bind("SUPER + SHIFT + ESCAPE",     hl.dsp.exit(),                                                 { description = "Exit Hyprland" })
hl.bind("SUPER + CTRL + ESCAPE",      hl.dsp.exec_cmd("reboot"),                                     { description = "Reboot" })
hl.bind("SUPER + SHIFT + CTRL + ESCAPE", hl.dsp.exec_cmd("systemctl poweroff"),                      { description = "Power off" })
hl.bind("SUPER + K",                  hl.dsp.exec_cmd("~/.nix-profile/bin/hyprland-show-keybinds"),  { description = "Show keybindings" })

-- Tiling control
hl.bind("SUPER + J", hl.dsp.layout("togglesplit"),             { description = "Toggle split direction" })
hl.bind("SUPER + P", hl.dsp.window.pseudo(),                   { description = "Toggle pseudotile" })
hl.bind("SUPER + V", hl.dsp.window.float({action = "toggle"}), { description = "Toggle floating" })

-- Resize active (relative). hl.dsp.window.resize takes {x, y, relative?, window?};
-- without relative=true it would set absolute size.
hl.bind("SUPER + minus",         hl.dsp.window.resize({x = -100, y = 0,    relative = true}), { description = "Resize active: narrower" })
hl.bind("SUPER + equal",         hl.dsp.window.resize({x =  100, y = 0,    relative = true}), { description = "Resize active: wider" })
hl.bind("SUPER + SHIFT + minus", hl.dsp.window.resize({x = 0,    y = -100, relative = true}), { description = "Resize active: shorter" })
hl.bind("SUPER + SHIFT + equal", hl.dsp.window.resize({x = 0,    y = 100,  relative = true}), { description = "Resize active: taller" })

-- Workspace scroll
hl.bind("SUPER + mouse_down", hl.dsp.focus({workspace = "e+1"}), { description = "Next workspace (scroll)" })
hl.bind("SUPER + mouse_up",   hl.dsp.focus({workspace = "e-1"}), { description = "Previous workspace (scroll)" })

-- Magic scratchpad
hl.bind("SUPER + S",         hl.dsp.workspace.toggle_special("magic"),               { description = "Toggle magic scratchpad" })
hl.bind("SUPER + SHIFT + S", hl.dsp.window.move({workspace = "special:magic"}),      { description = "Move window to magic scratchpad" })

-- Screenshots / color picker / clipboard
hl.bind("SUPER + PRINT",       hl.dsp.exec_cmd("hyprland-screenshot"),               { description = "Screenshot" })
hl.bind("CTRL + PRINT",        hl.dsp.exec_cmd("hyprpicker -a"),                     { description = "Color picker" })
hl.bind("CTRL + SUPER + V",    hl.dsp.exec_cmd("kitty --class clipse -e clipse"),    { description = "Clipboard history (clipse)" })

-- Mouse drag / resize
hl.bind("SUPER + mouse:272", hl.dsp.window.drag(),   { description = "Drag window",         mouse = true })
hl.bind("SUPER + mouse:273", hl.dsp.window.resize(), { description = "Resize window (drag)", mouse = true })

-- Multimedia (locked + repeating)
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { description = "Volume up",       locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),     { description = "Volume down",     locked = true, repeating = true })
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),    { description = "Mute output",     locked = true, repeating = true })
hl.bind("XF86AudioMicMute",     hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),  { description = "Mute microphone", locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp",  hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"),                 { description = "Brightness up",   locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"),                { description = "Brightness down", locked = true, repeating = true })

-- Media (locked only — playerctl ignores hold/repeat)
hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),       { description = "Media: next",       locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { description = "Media: play/pause", locked = true })
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"), { description = "Media: play/pause", locked = true })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),   { description = "Media: previous",   locked = true })

-- Emergency monitor restore (per-host, from generated.emergency_restore).
-- Re-applies every configured monitor, resumes hypridle, and herds workspaces
-- back to the primary output. Useful to recover if a remote-streaming session
-- leaves the physical display dpms-off / reconfigured.
if gen.emergency_restore.enable then
  hl.bind(gen.emergency_restore.key, function()
    for _, m in ipairs(gen.monitors) do
      hl.exec_cmd("hyprctl dispatch dpms on " .. m.output)
      hl.exec_cmd("hyprctl keyword monitor " .. m.output .. "," .. m.mode .. "," .. m.position .. "," .. m.scale)
    end
    hl.exec_cmd("pkill -CONT -x hypridle || true")
    local primary = gen.monitors[1]
    if primary then
      for ws = 1, 10 do
        hl.exec_cmd("hyprctl dispatch moveworkspacetomonitor " .. ws .. " " .. primary.output)
      end
      hl.exec_cmd("hyprctl dispatch focusmonitor " .. primary.output)
      hl.exec_cmd("hyprctl dispatch workspace 1")
    end
  end, { description = "Emergency: restore monitors" })
end
