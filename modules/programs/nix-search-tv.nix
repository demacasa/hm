{ config, lib, pkgs, ... }:

let
  cfg = config.hm.nixSearchTv;
in
{
  options.hm.nixSearchTv.enable = lib.mkEnableOption "nix-search-tv (ns) launcher";

  config = lib.mkIf cfg.enable {

    home.packages = with pkgs; [
      (pkgs.writeShellApplication {
        name = "ns";
        runtimeInputs = with pkgs; [
          fzf
          nix-search-tv
        ];
        excludeShellChecks = [ "SC2016" ];
        text = builtins.readFile "${pkgs.nix-search-tv.src}/nixpkgs.sh";
      })
    ];
  };
}
