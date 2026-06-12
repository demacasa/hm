{ config, lib, pkgs, ... }:
# Wallpaper PATH selection + autostart live in lua (see hyprland/generated.nix →
# generated.theme.wallpaper_path, consumed by hyprland/lua/main.lua). This module
# installs the awww package and, if the consumer provides a wallpaper directory
# via `hm.wallpaper.source`, copies it into ~/Pictures/Wallpapers. The image
# assets themselves are NOT shipped by this flake — the consumer supplies them.
let
  cfg = config.hm.wallpaper;
in
{
  options.hm.wallpaper = {
    enable = lib.mkEnableOption "Wallpaper management";
    source = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = ''
        Directory of wallpaper images to install into ~/Pictures/Wallpapers.
        File names must match the per-theme entries in hyprland/generated.nix.
        When null, no images are installed (only the awww package).
      '';
    };
  };

  config = lib.mkIf cfg.enable {

    home.file = lib.mkIf (cfg.source != null) {
      "Pictures/Wallpapers" = {
        source = cfg.source;
        recursive = true;
      };
    };

    home.packages = with pkgs; [ awww ];
  };
}
