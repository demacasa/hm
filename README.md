# hm

Reusable [Home Manager](https://github.com/nix-community/home-manager)
feature modules for demacasa@ machines.

## Usage

Import `homeManagerModules.default` into a Home Manager config and enable
features via `hm.<feature>.enable`:

```nix
{
  inputs.hm.url = "github:demacasa/hm";

  # in your home-manager modules:
  imports = [ inputs.hm.homeManagerModules.default ];

  hm = {
    # data inputs
    theme = "catppuccin-mocha";
    monitors = [ "HDMI-A-1,3840x2160@60,0x0,1.33" ];
    git = { userName = "Your Name"; userEmail = "you@example.com"; };

    # features
    nvim.enable = true;
    zsh.enable = true;
    theming.enable = true;
    hyprland.enable = true;
    waybar.enable = true;
  };
}
```

Every feature is flat and self-gating: `options.hm.<f>.enable` +
`config = mkIf cfg.enable { … }`. No module imports another. Importing the
default module exposes the full `hm.*` surface with everything off.

## Layout

```text
modules/
  options.nix     # hm.* data options (theme, monitors, git, …)
  programs/       # nvim, zsh, git, jujutsu, tmux, yazi, starship, fzf, …
  desktop/        # hyprland, waybar, wofi, mako, kew, wallpaper, theming
```
