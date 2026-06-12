# Checks that the rendered Hyprland lua config parses cleanly via
# `Hyprland --verify-config`. Catches lua-mode renderer regressions and syntax
# errors in the handwritten modules (main.lua etc.) before consumers hit them.
#
# All lua (hyprland.lua, generated.lua, and the handwritten modules) is staged
# by the sample HM activation under home-files/.config/hypr/ — see ./default.nix.
{ pkgs, hyprDir }:
pkgs.runCommand "hyprland-verify-config"
  {
    nativeBuildInputs = [ pkgs.hyprland ];
  }
  ''
    set -euo pipefail
    # Hyprland's lua package.path resolves require("foo") under
    # $XDG_CONFIG_HOME/hypr/, so stage every lua file there and verify.
    export XDG_RUNTIME_DIR=$(mktemp -d)
    export XDG_CONFIG_HOME=$(mktemp -d)
    mkdir -p "$XDG_CONFIG_HOME/hypr"
    cp -L "${hyprDir}/"*.lua "$XDG_CONFIG_HOME/hypr/"

    # --verify-config exits 0 on `config ok`, non-zero on parse errors.
    Hyprland --verify-config -c "$XDG_CONFIG_HOME/hypr/hyprland.lua"
    touch "$out"
  ''
