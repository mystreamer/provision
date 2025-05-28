{ pkgs, config, lib, inputs, ... }:
  {
    programs.zsh = {
      enable = true;
      oh-my-zsh = {
        enable = true;
        theme = "amuse";
        plugins = [
          "zsh-autosuggestions"
          "git"
        ];
      } ;
      initContent = ''
      . "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh"
      '';
    };   
  }