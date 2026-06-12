{ self, inputs, system }:
# Build one sample Home Manager configuration with the hyprland feature enabled,
# then validate its rendered lua. This makes the flake self-testing — no
# nixconfig / consumer required.
let
  pkgs = import inputs.nixpkgs {
    inherit system;
    config.allowUnfree = true;
  };

  sampleHome = inputs.home-manager.lib.homeManagerConfiguration {
    inherit pkgs;
    modules = [
      self.homeManagerModules.default
      {
        home.username = "demo";
        home.homeDirectory = "/home/demo";
        home.stateVersion = "26.05";

        # Representative data inputs (a real consumer wires these from its own
        # host config). theming is required so colorScheme is populated, which
        # hyprland/generated.nix and hyprlock.nix read.
        hm.theme = "catppuccin-mocha";
        hm.monitors = [ "HDMI-A-1,3840x2160@60,0x0,1.33" ];
        hm.hostName = "sample";
        hm.hasNvidia = false;

        hm.theming.enable = true;
        hm.hyprland.enable = true;
      }
    ];
  };

  # The activation stages every hypr lua file under home-files/.config/hypr/:
  # hyprland.lua (require("main") bootstrap), generated.lua, and the handwritten
  # main/look/system/windows/binds.lua (all store-backed).
  hyprDir = "${sampleHome.activationPackage}/home-files/.config/hypr";
in
{
  hyprland-config = import ./hyprland-config.nix { inherit pkgs hyprDir; };
  hyprland-luals = import ./hyprland-luals.nix { inherit pkgs hyprDir; };
}
