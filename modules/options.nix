{ lib, ... }:
{
  options.hm = {
    theme = lib.mkOption {
      type = lib.types.str;
      default = "catppuccin-mocha";
      description = "Base16/nix-colors theme name (a key in desktop/themes.nix).";
    };

    monitors = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = ''
        Monitor strings in "OUTPUT,MODE,POSITION,SCALE" form, e.g.
        "HDMI-A-1,3840x2160@60,0x0,1.33". Consumed by waybar (output list) and
        the hyprland generator.
      '';
    };

    hostName = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "Host name, surfaced to the hyprland lua config.";
    };

    hasNvidia = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to emit NVIDIA-specific hyprland env vars.";
    };

    configPath = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = ''
        Absolute path to the consumer's config checkout. Used ONLY for the zsh
        `nixvim`/`vimnix` editor aliases; when null those aliases are omitted.
      '';
    };

    git = {
      userName = lib.mkOption {
        type = lib.types.str;
        default = "";
        description = "git user.name.";
      };
      userEmail = lib.mkOption {
        type = lib.types.str;
        default = "";
        description = "git user.email.";
      };
    };

    quickAppBindings = lib.mkOption {
      # Each entry is consumed by lua/main.lua as
      # `hl.bind(keys, hl.dsp.exec_cmd(command), { description = description })`.
      type = lib.types.listOf (lib.types.submodule {
        options = {
          keys = lib.mkOption {
            type = lib.types.str;
            description = "Key combo in lua form, e.g. \"SUPER + G\".";
          };
          command = lib.mkOption {
            type = lib.types.str;
            description = "Shell command passed to hl.dsp.exec_cmd.";
          };
          description = lib.mkOption {
            type = lib.types.str;
            description = "Human-readable label for the show-keybindings menu.";
          };
        };
      });
      description = "Single-keystroke launchers for common apps (hyprland).";
      default =
        let
          terminal = "kitty";
          browser = "google-chrome-stable --new-window --ozone-platform=wayland --profile-directory=Default";
          webapp = "${browser} --app";
          fileManager = "yazi";
          music = "kew";
          passwordManager = "bitwarden";
        in
        [
          { keys = "SUPER + C"; description = "Launch WhatsApp (web app)"; command = "${webapp}=https://web.whatsapp.com/"; }
          { keys = "SUPER + return"; description = "Launch terminal"; command = "${terminal}"; }
          { keys = "SUPER + F"; description = "Launch file manager"; command = "${terminal} --class ${fileManager} -e ${fileManager}"; }
          { keys = "SUPER + B"; description = "Launch browser"; command = browser; }
          { keys = "SUPER + M"; description = "Launch music player"; command = "${terminal} --class ${music} -e ${music}"; }
          { keys = "SUPER + T"; description = "Launch btop"; command = "${terminal} --class btop -e btop"; }
          { keys = "SUPER + slash"; description = "Launch password manager"; command = passwordManager; }
          { keys = "SUPER + E"; description = "Emoji picker"; command = "wofi-emoji"; }
        ];
    };
  };
}
