{ pkgs, ... }:

# Home-manager config shared by the NixOS hosts, on top of ./default.nix.
{
  imports = [
    ./default.nix
    ../../programs/nvim
    ../../programs/zsh
    ../../programs/tmux
  ];

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    enableZshIntegration = true;
  };

  home.packages = with pkgs; [
    devenv
  ];

  # add to path
  home.sessionVariables = {
    PATH = "$PATH:$HOME/.local/bin";
  };
}
