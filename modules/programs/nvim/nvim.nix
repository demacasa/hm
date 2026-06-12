{ lib, pkgs, config, ... }:

let
  cfg = config.hm.nvim;
in
{
  options.hm.nvim.enable = lib.mkEnableOption "Neovim + LSP tooling";

  config = lib.mkIf cfg.enable {

    xdg.configFile."nvim/after" = {
      source = ./after;
      recursive = true;
    };

    xdg.configFile."nvim/lua/user_config" = {
      source = ./lua;
      recursive = true;
    };

    xdg.configFile."nvim/neovim_tips" = {
      source = ./neovim_tips;
      recursive = true;
    };

    home.packages = with pkgs; [
      # LSPs
      # keep-sorted start
      bash-language-server
      cargo # Used by nil LSP.
      go
      gopls
      lua-language-server
      nil
      nixpkgs-fmt
      prettierd
      pyright
      tree-sitter
      typos-lsp
      # keep-sorted end
    ];

    programs.neovim = {
      enable = true;
      defaultEditor = true;
      vimAlias = true;

      initLua = ''
        -- Bootstrap Lua configuration from ~/.config/nvim/lua/user_config/init.lua
        require('user_config')
      '';
    };
  };
}
