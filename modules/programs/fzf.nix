{ config, lib, ... }:

let
  cfg = config.hm.fzf;
in
{
  options.hm.fzf.enable = lib.mkEnableOption "fzf fuzzy finder";

  config = lib.mkIf cfg.enable {

    programs.fzf = {
      enable = true;
      # Disable by default since we'll use atuin.
      # Work computer will override.
      enableZshIntegration = lib.mkDefault false;
      enableBashIntegration = lib.mkDefault false;
      tmux.enableShellIntegration = true;
      defaultOptions = [ "--color 16" ];
    };
  };
}
