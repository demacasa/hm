{ config, lib, ... }:
let
  cfg = config.hm.hyprland;

  # Each handwritten lua module → ~/.config/hypr/<name>.lua from the store.
  # main.lua bootstraps the rest via require(). Edits need a rebuild.
  luaModules = [
    "main"
    "look"
    "system"
    "windows"
    "binds"
  ];
in
{
  imports = [
    ./generated.nix
    ./hypridle.nix
    ./hyprlock.nix
  ];

  options.hm.hyprland.enable = lib.mkEnableOption "Hyprland desktop (compositor, idle, lock)";

  config = lib.mkIf cfg.enable {
    wayland.windowManager.hyprland = {
      enable = true;
      # Single-line bootstrap into our handwritten lua. settings = {} so HM
      # doesn't render any hl.* calls itself; everything lives in lua/.
      extraConfig = ''require("main")'';
    };

    services.hyprpolkitagent.enable = true;

    xdg.configFile = builtins.listToAttrs (
      map
        (name: {
          name = "hypr/${name}.lua";
          value = {
            source = ./lua/${name}.lua;
          };
        })
        luaModules
    );
  };
}
