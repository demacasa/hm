# ╔════════════════════════════════════════════════════════════╗
# ║███████╗████████╗ █████╗ ██████╗ ███████╗██╗  ██╗██╗██████╗ ║
# ║██╔════╝╚══██╔══╝██╔══██╗██╔══██╗██╔════╝██║  ██║██║██╔══██╗║
# ║███████╗   ██║   ███████║██████╔╝███████╗███████║██║██████╔╝║
# ║╚════██║   ██║   ██╔══██║██╔══██╗╚════██║██╔══██║██║██╔═══╝ ║
# ║███████║   ██║   ██║  ██║██║  ██║███████║██║  ██║██║██║     ║
# ║╚══════╝   ╚═╝   ╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═╝╚═╝     ║
# ╚════════════════════════════════════════════════════════════╝

{ config, lib, hmInputs, pkgs, ... }:
let
  cfg = config.hm.starship;
  flavor = "mocha";
  jj = lib.getExe pkgs.jujutsu;
in
{
  options.hm.starship.enable = lib.mkEnableOption "Starship prompt";

  config = lib.mkIf cfg.enable {

    # https://gist.github.com/s-a-c/0e44dc7766922308924812d4c019b109#file-starship-nix/
    programs.starship = {
      enable = true;
      # https://starship.rs/config/
      settings = lib.recursiveUpdate (builtins.fromTOML (builtins.readFile "${hmInputs.catppuccin-starship}/themes/${flavor}.toml")) {
        add_newline = true;
        command_timeout = 1300;
        scan_timeout = 50;

        # https://github.com/catppuccin/catppuccin
        palette = "catppuccin_${flavor}";

        format = lib.concatStrings [
          "[┌───────────────────>](bold lavender)\n"
          "[│](bold lavender)$os$username$hostname$directory$battery\${custom.git_branch}\${custom.git_commit}\${custom.git_state}\${custom.git_status}$nix_shell\${custom.jj}\n"
          "[└─](bold lavenear)$character"
        ];

        username = {
          show_always = true;
          format = "[$user]($style) on ";
        };

        nix_shell = {
          format = "[$state]($style) ";
          pure_msg = "❄️";
          impure_msg = "🐚";
          unknown_msg = "❄️";
        };

        hostname = {
          ssh_only = false;
        };

        directory.substitutions = {
          "Documents" = "󰈙 ";
          "Downloads" = " ";
          "Music" = " ";
          "Images" = " ";
          "nixconfig" = "❄️";
        };

        custom = {
          jj = {
            description = "The current jj status";
            when = "jj --ignore-working-copy root";
            symbol = "[](bold blue) ";
            command = ''
              jj log --revisions @ --no-graph --ignore-working-copy --color always --limit 1 --template '
                separate(" ",
                  change_id.shortest(4),
                  bookmarks,
                  "|",
                  concat(
                    if(conflict, "💥"),
                    if(divergent, "🚧"),
                    if(hidden, "👻"),
                    if(immutable, "🔒"),
                  ),
                  raw_escape_sequence("\x1b[1;32m") ++ if(empty, "(empty)"),
                  raw_escape_sequence("\x1b[1;32m") ++ coalesce(
                    truncate_end(29, description.first_line(), "…"),
                    "∅",
                  ) ++ raw_escape_sequence("\x1b[0m"),
                )
              '
            '';
          };

          git_branch = {
            when = "! ${jj} --ignore-working-copy root";
            command = "starship module git_branch";
            style = ""; # This disables the default "(bold green)" style
            description = "Only show git_branch if we're not in a jj repo";


          };
          git_commit = {
            when = "! ${jj} --ignore-working-copy root";
            command = "starship module git_commit";
            style = "";
            description = "Only show git_commit if we're not in a jj repo";
          };
          git_state = {
            when = "! ${jj} --ignore-working-copy root";
            command = "starship module get_state";
            style = "";
            description = "Only show git_state if we're not in a jj repo";
          };
          git_status = {
            when = "! ${jj} --ignore-working-copy root";
            command = "starship module git_status";
            style = "";
            description = "Only show git_status if we're not in a jj repo";
          };
        };
        git_state = {
          disabled = true;
        };

        git_status = {
          disabled = true;
        };

        git_commit = {
          disabled = true;
        };

        git_metrics = {
          disabled = true;
        };

        git_branch = {
          disabled = true;
        };
      };
    };
  };
}
