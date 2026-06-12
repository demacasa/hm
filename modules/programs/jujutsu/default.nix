{ lib, pkgs, config, ... }:
let
  cfg = config.hm.jujutsu;
in
{
  options.hm.jujutsu.enable = lib.mkEnableOption "Jujutsu VCS";

  config = lib.mkIf cfg.enable {

    home.packages = with pkgs; [
      jujutsu
      lazyjj
    ];

    # Static config + a [user] section generated from the shared hm.git.*
    # identity (kept out of the committed config.toml so it stays generic).
    xdg.configFile."jj/config.toml" = {
      text = builtins.readFile ./config.toml + ''

        [user]
        name = "${config.hm.git.userName}"
        email = "${config.hm.git.userEmail}"
      '';
    };
  };
}
