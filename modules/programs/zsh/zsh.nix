{ lib, config, pkgs, ... }:

let
  cfg = config.hm.zsh;
in
{
  options.hm.zsh.enable = lib.mkEnableOption "Zsh shell";

  config = lib.mkIf cfg.enable {


    # https://search.nixos.org/packages?channel=unstable&show=zsh-f-sy-h&from=0&size=30&sort=relevance&type=packages&query=zsh
    home.packages = with pkgs; [
      zsh-autosuggestions
      zsh-completions
      zsh-f-sy-h # syntax highlighting
      zsh-nix-shell
      zsh-vi-mode
    ];

    xdg.configFile."zsh/functions.zsh".source = ./functions.zsh;

    programs.zsh = {
      enable = true;

      # TODO(#738): pinning legacy $HOME dotDir. 26.05 HM defaults to
      # `~/.config/zsh`; migration is a one-way file move.
      dotDir = config.home.homeDirectory;

      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;
      autocd = true;
      enableCompletion = true;

      plugins = with pkgs; [
        {
          name = "zsh-vi-mode";
          src = "${zsh-vi-mode}/share/zsh-vi-mode";
        }
        {
          name = "zsh-nix-shell";
          file = "nix-shell.plugin.zsh";
          src = "${zsh-nix-shell}/share/zsh-nix-shell";
        }
      ];

      history = {
        size = 10000;
        path = "${config.xdg.dataHome}/zsh/history";
        append = true;
        extended = true;
        ignoreDups = true;
        ignoreSpace = true;
      };

      shellAliases = {
        zsource = "source ~/.zshrc";
        zshrc = "vim ~/.zshrc";
      }
      # `nixvim`/`vimnix` open the consumer's config checkout; only meaningful
      # when the consumer points hm.configPath at it.
      // lib.optionalAttrs (config.hm.configPath != null) {
        nixvim = "vim ${config.hm.configPath}";
        vimnix = "vim ${config.hm.configPath}";
      };

      sessionVariables = {
        ZVM_SYSTEM_CLIPBOARD_ENABLED = true;
        ZVM_LINE_INIT_MODE = "i";

        FZF_CTRL_T_OPTS = ''
          --walker-skip .git,node_modules,target
          --preview 'bat -n --color=always {}'
          --bind 'ctrl-/:change-preview-window(down|hidden|)'
        '';
        FZF_ALT_C_OPTS = ''
          --walker-skip .git,node_modules,target
          --preview 'tree -C {}'
        '';
      };

      initContent = ''
        source ${config.xdg.configHome}/zsh/functions.zsh

        # Tab-able aliases.
        function cat() { command bat --paging=never "$@"; }

        # Eza Aliases
        unalias l ls ll la lla lal tree 2>/dev/null
        function l() { command eza "$@"; }
        function ls() { command eza --icons "$@"; }
        function ll() { command eza -lg "$@"; }
        function la() { command eza -a "$@"; }
        function lla() { command eza -lga "$@"; }
        function lal() { command eza -lga "$@"; }
        function tree() { command eza --tree "$@"; }

        t() {
          tmux new-session -A -s main
        }

        # Automatically start tmux for interactive SSH sessions.
        # Conditions:
        # 1. -n "$SSH_CONNECTION": Checks if this is an SSH session.
        # 2. -z "$TMUX":           Checks that we are not already inside tmux.
        # 3. $- == *i*:           Ensures the shell is interactive.
        if [[ -n "$SSH_CONNECTION" && -z "$TMUX" && $- == *i* ]]; then
          # Attach to session "main" if it exists, otherwise create it.
          # No 'exec' is used, so exiting tmux returns you to the shell.
          t
        fi

        # Disable XON/XOFF flow control (Ctrl-S/Ctrl-Q)
        stty -ixon

        function set_win_title(){
          echo -ne "\033]0; $PWD \007"
        }
        precmd_functions+=(set_win_title)

        # Use LS_COLORS for file completion coloring
        zstyle ':completion:*' list-colors "''${(s.:.)LS_COLORS}"

        # Shift + Tab completes auto suggestions.
        bindkey '^[[Z' autosuggest-accept

        fastfetch
      '';
    };
  };
}
