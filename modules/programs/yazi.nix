{ config, lib, ... }:


let
  cfg = config.hm.yazi;
in
{
  options.hm.yazi.enable = lib.mkEnableOption "Yazi file manager";

  config = lib.mkIf cfg.enable {

    programs.yazi = {
      enable = true;
      shellWrapperName = "yy";
      settings = {
        manager = {
          ratio = [
            1 # left
            3 # middle
            3 # right
          ];
          sort_by = "natural";
          sort_sensitive = true;
          sort_dir_first = true;
          linemode = "size";
          show_hidden = true;
          show_symlink = true;
          title_format = "yazi @ {cwd}";
          mouse_events = [
            "click"
            "scroll"
            "touch"
            "move"
            "drag"
          ];
        };
      };
    };
  };
}
