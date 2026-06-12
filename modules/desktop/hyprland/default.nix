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

  options.hm.hyprland = {
    enable = lib.mkEnableOption "Hyprland desktop (compositor, idle, lock)";

    headlessOutputs = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      example = [ "HEADLESS-1,1920x1080@60,9999x0,1" ];
      description = ''
        Monitor specs for headless outputs to create on hyprland.start (e.g. a
        deterministic output for remote streaming). Each entry is created via
        `hyprctl output create headless` then configured with `keyword monitor`.
        Names are assigned in order (HEADLESS-1, HEADLESS-2, …).
      '';
    };

    emergencyRestore = {
      enable = lib.mkEnableOption "emergency keybind that restores hm.monitors + resumes hypridle";
      key = lib.mkOption {
        type = lib.types.str;
        default = "SUPER + SHIFT + F12";
        description = "Keybind for the emergency monitor-restore action.";
      };
    };
  };

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
