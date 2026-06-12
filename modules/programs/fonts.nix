{ config, lib, pkgs, ... }:


let
  cfg = config.hm.fonts;
in
{
  options.hm.fonts.enable = lib.mkEnableOption "Noto + Nerd Fonts";

  config = lib.mkIf cfg.enable {

    fonts.fontconfig.enable = true;
    home.packages = with pkgs; [
      noto-fonts
      # Loads the complete collection of nerd-fonts.
    ] ++ builtins.filter lib.attrsets.isDerivation (builtins.attrValues pkgs.nerd-fonts);
  };
}
