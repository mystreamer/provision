{ pkgs, config, lib, inputs, ... }:
  {
    programs.tmux = {
      enable = true;
      extraConfig = ''
      set -s set-clipboard on
      '';
    };   
  }
