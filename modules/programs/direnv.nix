{ config, lib, ... }:
let
  cfg = config.hm.direnv;
in
{
  options.hm.direnv.enable = lib.mkEnableOption "direnv + nix-direnv";

  config = lib.mkIf cfg.enable {

    programs.direnv = {
      enable = true;
      enableZshIntegration = true;
      nix-direnv.enable = true;
      silent = true;
    };
  };
}
