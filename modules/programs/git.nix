{ lib, config, pkgs, ... }:


let
  cfg = config.hm.git;
in
{
  options.hm.git.enable = lib.mkEnableOption "Git";

  config = lib.mkIf cfg.enable {

    home.packages = [ pkgs.git ];
    programs.git = {
      enable = true;
      settings = {
        user = {
          name = config.hm.git.userName;
          email = config.hm.git.userEmail;
        };
        init.defaultBranch = "main";
        pull.rebase = "true";
        merge.renameLimit = "999999";
        diff.renameLimit = "999999";
      };
    };

    xdg.configFile."git/.repo_config.json".text = ''
      {
        "init.defaultbranch": [
          "main"
        ],
        "diff.renamelimit": [
          "999999"
        ],
        "merge.renamelimit": [
          "999999"
        ],
        "pull.rebase": [
          "true"
        ],
        "user.email": [
          "${config.hm.git.userEmail}"
        ],
        "user.name": [
          "${config.hm.git.userName}"
        ]
      }
    '';
  };
}
