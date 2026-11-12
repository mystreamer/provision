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
  home-manager.users.dylan = {
      imports = [ ../../modules/home/nixos.nix ];
      home.stateVersion = "26.05";
  };
}
