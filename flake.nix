{
  description = "Reusable, composition-agnostic Home Manager feature modules for demacasa@";

  # nixpkgs + home-manager are only needed to build the sample Home Manager
  # config used by `checks` (see ./checks). Consumers should add
  # `inputs.<name>.follows` for all of these to avoid duplicate inputs.
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    catppuccin = {
      url = "github:catppuccin/nix/release-25.11";
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
            # Imported here at the wrapper level (not inside theming.nix) so the
            # submodules' own `imports` never need a module arg, which the module
            # system can't resolve. They are inert until `hm.theming.enable`.
            inputs.catppuccin.homeModules.catppuccin
            inputs.nix-colors.homeManagerModules.default
          ];

          # Thread this flake's inputs to every feature module's `config`/`let`
          # as `hmInputs` (used by theming, hyprlock, starship).
          _module.args.hmInputs = inputs;
        };

      # Self-contained checks: build a sample HM config that enables the
      # hyprland feature, then validate the rendered lua. No consumer needed.
      checks = forAllSystems (system: import ./checks { inherit self inputs system; });
    };
}
