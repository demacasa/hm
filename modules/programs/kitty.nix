{ lib, config, ... }:
let
  cfg = config.hm.kitty;
  # kitty-scrollback.nvim is installed by vim.pack into nvim's data dir; its
  # bundled python kitten lives at this stable path. Pointing kitty at the
  # same checkout the lua plugin loads keeps the two versions in lockstep.
  ksbKitten = "${config.home.homeDirectory}/.local/share/nvim/site/pack/core/opt/kitty-scrollback.nvim/python/kitty_scrollback_nvim.py";
in
{
  options.hm.kitty.enable = lib.mkEnableOption "Kitty terminal";

  config = lib.mkIf cfg.enable {

    programs.kitty = {
      enable = true;

      # New tabs/windows open in the same directory as the current one.
      # Relies on shell_integration (enabled below) tracking the cwd.
      # New windows always open as a vertical split (side-by-side, new pane
      # to the right) via the `splits` layout enabled below.
      keybindings = {
        "ctrl+shift+t" = "launch --cwd=current --type=tab";
        "ctrl+shift+enter" = "launch --cwd=current --location=vsplit";
        "ctrl+shift+n" = "new_os_window_with_cwd";

        # Vim-style pane navigation + resize for the splits layout.
        "ctrl+shift+h" = "neighboring_window left";
        "ctrl+shift+j" = "neighboring_window down";
        "ctrl+shift+k" = "neighboring_window up";
        "ctrl+shift+l" = "neighboring_window right";
        "ctrl+shift+r" = "start_resizing_window";

        # Zoom the focused pane to full screen and back. This toggles the
        # `stack` layout on/off (returning to `splits`), which is the only
        # sensible use of `stack` here. We deliberately do NOT bind
        # `next_layout`: with just splits+stack it silently lands you in
        # `stack`, where every new window is full-screen and splitting looks
        # broken. `toggle_layout` always returns to the previous (splits) layout.
        "ctrl+shift+z" = "toggle_layout stack";
      };

      font = {
        name = "FiraCode Nerd Font";
        size = 14;
      };

      settings = {
        # -- Fonts --
        bold_font = "auto";
        italic_font = "auto";
        bold_italic_font = "auto";
        adjust_line_height = 0;
        # Keep FiraCode ligatures but un-merge them on the cursor's line.
        disable_ligatures = "cursor";

        # -- Cursor --
        cursor_text_color = "background";
        cursor_shape = "block";
        cursor_blink_interval = 0.5;
        # Smooth trailing animation when the cursor jumps (kitty >= 0.36).
        cursor_trail = 3;

        # -- Scrollback --
        scrollback_lines = 5000;

        # -- Mouse --
        mouse_hide_wait = 2.0;
        url_style = "curly";
        open_url_with = "default";
        detect_urls = "yes";
        copy_on_select = "yes";
        strip_trailing_spaces = "smart";
        select_by_word_characters = "@-./_~?&=%+#";

        # -- Terminal Bell --
        enable_audio_bell = false;
        visual_bell_duration = 0.0;

        # -- Window Layout & Appearance --
        # splits first => it's the default layout, so new panes split rather
        # than stack. stack kept as a secondary (toggle with the layout key).
        enabled_layouts = "splits,stack";
        remember_window_size = true;
        initial_window_width = 960;
        initial_window_height = 600;
        window_padding_width = 0;
        window_border_width = 0.5;
        background_opacity = "0.95";
        dynamic_background_opacity = "yes";
        # Close without the "processes still running" prompt.
        confirm_os_window_close = 0;

        # -- Tab Bar --
        tab_bar_style = "powerline";
        tab_powerline_style = "slanted";
        tab_bar_align = "left";
        tab_bar_min_tabs = 2;
        # Show the tab index plus the basename of its active directory.
        tab_title_template = ''"{index}: {tab.active_wd.rsplit('/', 1)[-1]}"'';

        # -- Advanced --
        term = "xterm-kitty";
        # Required by kitty-scrollback.nvim (see extraConfig below). socket-only
        # is the plugin's preferred value: control only via the per-instance
        # socket, never the TTY. The socket name is per-pid so multiple kitty
        # windows each get their own.
        allow_remote_control = "socket-only";
        listen_on = "unix:/tmp/kitty-{kitty_pid}";
        shell_integration = "enabled no-sudo no-cursor";
        paste_actions = "quote-urls-at-prompt";
        # Desktop notification when a long (>10s) command finishes in an
        # unfocused window. Needs shell_integration (enabled above).
        notify_on_cmd_finish = "unfocused 10.0";

        # -- Catppuccin Mocha Theme --
        foreground = "#cdd6f4";
        background = "#1e1e2e";
        selection_foreground = "#1e1e2e";
        selection_background = "#f5e0dc";

        cursor = "#f5e0dc";
        # cursor_text_color set above

        url_color = "#f5e0dc";

        active_border_color = "#b4befe";
        inactive_border_color = "#6c7086";
        bell_border_color = "#f9e2af";

        wayland_titlebar_color = "system";
        macos_titlebar_color = "system";

        active_tab_foreground = "#11111b";
        active_tab_background = "#cba6f7";
        inactive_tab_foreground = "#cdd6f4";
        inactive_tab_background = "#181825";
        tab_bar_background = "#11111b";

        mark1_foreground = "#1e1e2e";
        mark1_background = "#b4befe";
        mark2_foreground = "#1e1e2e";
        mark2_background = "#cba6f7";
        mark3_foreground = "#1e1e2e";
        mark3_background = "#74c7ec";

        # -- 16 Terminal Colors --
        color0 = "#45475a";
        color8 = "#585b70";
        color1 = "#f38ba8";
        color9 = "#f38ba8";
        color2 = "#a6e3a1";
        color10 = "#a6e3a1";
        color3 = "#f9e2af";
        color11 = "#f9e2af";
        color4 = "#89b4fa";
        color12 = "#89b4fa";
        color5 = "#f5c2e7";
        color13 = "#f5c2e7";
        color6 = "#94e2d5";
        color14 = "#94e2d5";
        color7 = "#bac2de";
        color15 = "#a6adc8";
      };

      # kitty-scrollback.nvim wiring. Kept in extraConfig (not keybindings) so
      # action_alias is defined before the maps that reference it. Browse keys
      # avoid ctrl+shift+h/j/k/l, which are taken by pane navigation above.
      extraConfig = ''
        action_alias kitty_scrollback_nvim kitten ${ksbKitten}

        # Browse the full scrollback buffer in nvim.
        map ctrl+shift+s kitty_scrollback_nvim
        # Browse the output of the last shell command in nvim.
        map ctrl+shift+g kitty_scrollback_nvim --config ksb_builtin_last_cmd_output
        # Show a clicked command's output in nvim.
        mouse_map ctrl+shift+right press ungrabbed combine : mouse_select_command_output : kitty_scrollback_nvim --config ksb_builtin_last_visited_cmd_output
      '';
    };
  };
}
