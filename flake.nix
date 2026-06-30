{
  description = "Reusable Home Manager feature modules for demacasa@";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    catppuccin = {
      url = "github:catppuccin/nix/release-26.05";
    };
    nix-colors.url = "github:misterio77/nix-colors";
    catppuccin-starship = {
      url = "github:catppuccin/starship";
      flake = false;
    };
  };

  outputs =
    { self, nixpkgs, ... }@inputs:
    let
      systems = [ "x86_64-linux" ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
    in
    {
      homeManagerModules.default =
        { ... }:
        {
          imports = [
            ./modules
            inputs.catppuccin.homeModules.catppuccin
            inputs.nix-colors.homeManagerModules.default
          ];
          _module.args.hmInputs = inputs;
        };

      checks = forAllSystems (system: import ./checks { inherit self inputs system; });
    };
}
