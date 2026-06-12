{ config, lib, ... }:

let
  cfg = config.hm.atuin;
in
{
  options.hm.atuin.enable = lib.mkEnableOption "Atuin shell history";

  config = lib.mkIf cfg.enable {

    programs.atuin = {
      enable = true;
      enableZshIntegration = true;

      settings = {
        search_mode = "fuzzy";
        inline_height = 20;
        show_preview = false;
        enter_accept = true;
        theme = {
          name = "catppuccin-mocha-blue";
        };
      };

      flags = [
        "--disable-up-arrow"
      ];

      # https://github.com/catppuccin/atuin
      themes = {
        "catppuccin-mocha-blue" = {
          theme.name = "catppuccin-mocha-blue";
          colors = {
            AlertInfo = "#a6e3a1";
            AlertWarn = "#fab387";
            AlertError = "#f38ba8";
            Annotation = "#89b4fa";
            Base = "#cdd6f4";
            Guidance = "#9399b2";
            Important = "#f38ba8";
            Title = "#89b4fa";
          };
        };

        "catppuccin-mocha-flamingo" = {
          theme.name = "catppuccin-mocha-flamingo";
          colors = {
            AlertInfo = "#a6e3a1";
            AlertWarn = "#fab387";
            AlertError = "#f38ba8";
            Annotation = "#f2cdcd";
            Base = "#cdd6f4";
            Guidance = "#9399b2";
            Important = "#f38ba8";
            Title = "#f2cdcd";
          };
        };
      };
    };

    programs.zsh.initContent = ''
      function zvm_after_init() {
        zvm_bindkey viins '^r' atuin-search
      }
    '';
  };
}
