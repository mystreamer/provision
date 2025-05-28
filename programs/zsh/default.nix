{ pkgs, config, lib, inputs, ... }:
  {
    programs.vim = {
      enable = true;
      initContent = ''
      . "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh"
      '';
    };   
  }