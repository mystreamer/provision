# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ../../modules/nixos-base.nix
      ../../modules/desktop.nix
    ];


  # Do not change after install; see `man configuration.nix` / nixos.org options for stateVersion.
  system.stateVersion = "25.05";

  ### SYSTEM-APPS ###
  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    gnumake
    ghc
    haskell-language-server
    stack
    cabal-install
    # helix
    nodejs
    ripgrep
    up
    # jdk21_headless
    # llvmPackages_17.libllvm
    # llvmPackages_17.libcxxClang
    swi-prolog
  ];

  # make java available on JAVA_HOME
  programs.java.enable = true;

  ### HOME MANAGER ###
  home-manager.users.dylan = { pkgs, lib, inputs, config, ... }: {
      imports = [
        ../../programs/nvim
        ../../programs/zsh
        ../../programs/tmux
      ];

      # git config (TODO: deduplicate with mac setup)
      programs.git = {
        enable = true;
        settings = {
          user.name = "mystreamer";
          user.email = "me@dylanmassey.ch";
          init.defaultBranch = "main";
        };
      };

      programs.direnv = {
        enable = true;
        nix-direnv.enable = true;
        enableZshIntegration = true;
      };

      programs.home-manager.enable = true;
      home.stateVersion = "26.05";

      home.packages = with pkgs; [
        devenv
      ];

      # add to path
      home.sessionVariables = {
        PATH = "$PATH:$HOME/.local/bin"; 
      };
  };
}
