{ config, lib, ... }:

let
  cfg = config.hm.zoxide;
in
{
  options.hm.zoxide.enable = lib.mkEnableOption "zoxide directory jumper";

  config = lib.mkIf cfg.enable {

    programs.zoxide = {
      enable = true;
      options = [ "--cmd cd" ];
      enableZshIntegration = true;
    };

    # Silence zoxide's doctor: it false-positives in shells that clear
    # chpwd_functions (e.g. Claude Code's Bash tool).
    home.sessionVariables._ZO_DOCTOR = "0";
  };
}
