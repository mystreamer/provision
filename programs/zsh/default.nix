{ pkgs, config, lib, inputs, ... }:
  {
    programs.zsh = {
      enable = true;
      autosuggestion.enable = true;
      oh-my-zsh = {
        enable = true;
        theme = "amuse";
        plugins = [
          "git"
        ];
      } ;
      initContent = 
      let 
        ranger_cmd = builtins.readFile .ranger.zsh;
      in
      ''
      source ${pkgs.zsh-vi-mode}/share/zsh-vi-mode/zsh-vi-mode.plugin.zsh
      . "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh"
      source  ${ranger_cmd}
      '';
    };   
  }
