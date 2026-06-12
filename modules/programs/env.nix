{ config, lib, ... }:


let
  cfg = config.hm.shellEnv;
in
{
  options.hm.shellEnv.enable = lib.mkEnableOption "Shell environment variables (EDITOR/VISUAL)";

  config = lib.mkIf cfg.enable {

    home.sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
    };
  };
}
