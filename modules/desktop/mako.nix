{ config, lib, ... }:

let
  cfg = config.hm.mako;
in
{
  options.hm.mako.enable = lib.mkEnableOption "Mako notifications";

  config = lib.mkIf cfg.enable {

    services.mako = {
      enable = true;

      settings = {
        background-color = lib.mkDefault "#${config.colorScheme.palette.base00}";
        text-color = lib.mkDefault "#${config.colorScheme.palette.base05}";
        border-color = lib.mkDefault "#${config.colorScheme.palette.base04}";
        progress-color = lib.mkDefault "#${config.colorScheme.palette.base0D}";

        width = 420;
        height = 110;
        padding = "10";
        margin = "10";
        border-size = 2;
        border-radius = 0;

        anchor = "top-right";
        layer = "overlay";

        default-timeout = 5000;
        ignore-timeout = false;
        max-visible = 5;
        sort = "-time";

        group-by = "app-name";

        actions = true;

        format = "<b>%s</b>\\n%b";
        markup = true;
      };
    };
  };
}
