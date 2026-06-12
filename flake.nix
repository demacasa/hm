{
  description = "Reusable, composition-agnostic Home Manager feature modules for demacasa@";

  # The feature modules consume the consumer's Home Manager module args
  # (config/lib/pkgs) plus this flake's own theming inputs, threaded to every
  # submodule as the `hmInputs` module arg (see outputs below). A consumer only
  # needs to import `homeManagerModules.default`; it does not have to pass
  # catppuccin/nix-colors/catppuccin-starship itself.
  inputs = {
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
    inputs:
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
    };
}
