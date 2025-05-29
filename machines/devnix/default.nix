# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, input, pkgs, lib, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Systemd mount dirs
  systemd.tmpfiles.rules = [
    "d /mnt 0755 root root -" # generally for ephemeral mounts
    "d /media 0755 root root -"
  ];

  # networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Stockholm";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "sv_SE.UTF-8";
    LC_IDENTIFICATION = "sv_SE.UTF-8";
    LC_MEASUREMENT = "sv_SE.UTF-8";
    LC_MONETARY = "sv_SE.UTF-8";
    LC_NAME = "sv_SE.UTF-8";
    LC_NUMERIC = "sv_SE.UTF-8";
    LC_PAPER = "sv_SE.UTF-8";
    LC_TELEPHONE = "sv_SE.UTF-8";
    LC_TIME = "sv_SE.UTF-8";
  };

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "ch";
    variant = "fr_mac";
  };

  # Configure console keymap
  console.keyMap = "sg";

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.dylan = {
    isNormalUser = true;
    description = "dylan";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # hardware.parallels.enable = true;

  services.openssh.enable = true;
  services.envfs.enable = true;

  # enable experimental features
  nix = {
    package = pkgs.nix;
    settings.experimental-features = [ "nix-command" "flakes" ];
  };

  environment.etc."inputrc".text = ''
   set editing-mode vi
  '';

  # Needed to enable remote development using VSCode SSH-Remote Plugin
  programs.nix-ld.enable = true;

  services.xserver = {
  	enable = true;
  	displayManager.gdm.enable = true;
  	desktopManager.gnome.enable = true;
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?

  ### VIRTUALISATION ###
  virtualisation.docker.enable = true;
  users.extraGroups.docker.members = [ "dylan" ];

  ### SYSTEM-APPS ###
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    git
    gnumake
    tmux
    ncdu
    lazygit
    ghc
    stack
    cabal-install
    neofetch
    helix
    nodejs
    fzf
    up
    uv
    ranger
  ];

  # specific problem with nixpkgs-ranger (TODO: Also apply to devmac)
  # Overlays for nixpkgs
  nixpkgs.overlays = [
    (self: super:
    {
      # overlay, because of this issue: 
      # https://github.com/phantasea/ranger/commit/52ae31fdac991808f0bb6af6187145fc60e32223
      ranger = super.ranger.overrideAttrs (oldAttrs: rec {
        src = super.fetchFromGitHub {
          owner = "ranger";
          repo = "ranger";
          rev = "4031ee1564ab36fed1dfcb1c1e859a1d674ba007";
          hash = "sha256-uMvo+5I5WCJGT5+XRS/NFClDGH4F59ogQJb+RYuraX4=";
        };
      });
    })
  ];

  # set zsh as default shell
  programs.zsh.enable = true;
  users.users.dylan.shell = pkgs.zsh;

  ### HOME MANAGER ###
  home-manager.users.dylan = { pkgs, lib, inputs, config, ... }: {
      imports = [
        ../../programs/vim
        ../../programs/zsh
        ../../programs/tmux
      ];


      # git config (TODO: deduplicate with mac setup)
      programs.git = {
        enable = true;
        userName = "mystreamer";
        userEmail = "me@dylanmassey.ch";
        extraConfig = {
          init.defaultBranch = "main";
        };
      };

      programs.home-manager.enable = true;
      home.stateVersion = "25.05";

      # add to path
      home.sessionVariables = {
        PATH = "$PATH:$HOME/.local/bin"; 
      };
  };
}
