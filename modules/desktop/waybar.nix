{ config, lib, ... }:

let
  cfg = config.hm.waybar;
in
{
  options.hm.waybar.enable = lib.mkEnableOption "Waybar status bar";

  config = lib.mkIf cfg.enable {

    home.file = {
      ".config/waybar/" = {
        source = ./config/waybar;
        recursive = true;
      };
      ".config/waybar/theme.css" = {
        text = ''
          * {
            color: #${config.colorScheme.palette.base05};
            background-color: #${config.colorScheme.palette.base00};
          }
        '';
      };
    };

    programs.waybar = {
      enable = true;
      settings = [
        {
          output = map (m: builtins.head (lib.splitString "," m)) config.hm.monitors;
          layer = "top";
          position = "top";
          spacing = 0;
          height = 36;
          modules-left = [
            "hyprland/workspaces"
          ];
          modules-center = [
            "clock"
          ];
          modules-right = [
            "tray"
            "custom/caffeine"
            "bluetooth"
            "network"
            "wireplumber"
            "cpu"
            "power-profiles-daemon"
            "battery"
          ];
          "hyprland/workspaces" = {
            on-click = "activate";
            format = "{icon} ({name})";
            format-icons = {
              "1" = ""; # Terminal
              "2" = ""; # Chrome/Browser
              "3" = "✨"; # Gemini
              "4" = ""; # File Browser
              "5" = ""; # btop/System
              "10" = "󱓧"; # Notes
              default = ""; # Default dot icon
              active = "󱓻";
            };
            persistent-workspaces = {
              "1" = [ ];
              "2" = [ ];
              "3" = [ ];
              "4" = [ ];
              "5" = [ ];
              "6" = [ ];
              "10" = [ ];
            };
          };
          cpu = {
            interval = 5;
            format = "󰍛";
            on-click = "kitty -e btop";
          };
          clock = {
            format = "{:%A %I:%M %p}";
            format-alt = "{:%d %B W%V %Y}";
            tooltip = false;
          };
          network = {
            format-icons = [ "󰤯" "󰤟" "󰤢" "󰤥" "󰤨" ];
            format = "{icon}";
            format-wifi = "{icon}";
            format-ethernet = "󰀂";
            format-disconnected = "󰖪";
            tooltip-format-wifi = "{essid} ({frequency} GHz)\n⇣{bandwidthDownBytes}  ⇡{bandwidthUpBytes}";
            tooltip-format-ethernet = "⇣{bandwidthDownBytes}  ⇡{bandwidthUpBytes}";
            tooltip-format-disconnected = "Disconnected";
            interval = 3;
            nospacing = 1;
            on-click = "kitty -e nmtui";
          };
          battery = {
            interval = 5;
            format = "{capacity}% {icon}";
            format-discharging = "{icon}";
            format-charging = "{icon}";
            format-plugged = "";
            format-icons = {
              charging = [
                "󰢜"
                "󰂆"
                "󰂇"
                "󰂈"
                "󰢝"
                "󰂉"
                "󰢞"
                "󰂊"
                "󰂋"
                "󰂅"
              ];
              default = [
                "󰁺"
                "󰁻"
                "󰁼"
                "󰁽"
                "󰁾"
                "󰁿"
                "󰂀"
                "󰂁"
                "󰂂"
                "󰁹"
              ];
            };
            format-full = "Charged ";
            tooltip-format-discharging = "{power:>1.0f}W↓ {capacity}%";
            tooltip-format-charging = "{power:>1.0f}W↑ {capacity}%";
            states = {
              warning = 20;
              critical = 10;
            };
          };
          bluetooth = {
            format = "󰂯";
            format-disabled = "󰂲";
            format-connected = "";
            tooltip-format = "Devices connected: {num_connections}";
            on-click = "GTK_THEME=Adwaita-dark blueberry";
          };
          wireplumber = {
            # Changed from "pulseaudio"
            "format" = "";
            format-muted = "󰝟";
            scroll-step = 5;
            on-click = "GTK_THEME=Adwaita-dark pavucontrol";
            tooltip-format = "Playing at {volume}%";
            on-click-right = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"; # Updated command
            max-volume = 150; # Optional: allow volume over 100%
          };
          power-profiles-daemon = {
            format = "{icon}";
            tooltip-format = "Power profile: {profile}";
            tooltip = true;
            format-icons = {
              power-saver = "󰡳";
              balanced = "󰊚";
              performance = "󰡴";
            };
          };

          "custom/caffeine" = {
            format = "{text}";
            tooltip = true;
            exec = "caffeine status";
            return-type = "json";
            interval = 5; # seconds
            on-click = "caffeine toggle";
          };
        }
      ];
    };
  };
}
