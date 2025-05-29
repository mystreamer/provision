{ pkgs, config, lib, inputs, ... }:
  {
    programs.tmux = {
      enable = true;
      extraConfig = ''
      set -s set-clipboard on
      set -g default-terminal "tmux-256color"
      set -ga terminal-overrides ",*256col*:Tc"
      '';
    };   
  }
