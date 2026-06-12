{ config, lib, hmInputs, ... }:
let
  cfg = config.hm.theming;

  themes = import ./themes.nix;
  selectedTheme = themes.${config.hm.theme};

  # e.g. "catppuccin-mocha" -> [ "catppuccin" "mocha" ]
  themeParts = lib.strings.splitString "-" config.hm.theme;
  themeBase = lib.elemAt themeParts 0;
in
{
  # The catppuccin + nix-colors home-manager modules are imported by the flake's
  # `homeManagerModules.default` wrapper, so they are available here without this
  # module needing a module arg in its own `imports`.
  options.hm.theming.enable = lib.mkEnableOption "nix-colors colorScheme + catppuccin theming";

  config = lib.mkIf cfg.enable {
    colorScheme = hmInputs.nix-colors.colorSchemes.${selectedTheme.base16-theme};

    catppuccin = lib.mkIf (themeBase == "catppuccin") {
      flavor = "mocha";
      btop.enable = true;
      mako.enable = true;
      yazi.enable = true;
      # hyprland.enable = true;
      kitty.enable = true;
      # gtk.enable = true;
      fzf.enable = true;
      bat.enable = true;
    };
  };
}
