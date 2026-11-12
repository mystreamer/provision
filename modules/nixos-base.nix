{ pkgs, vscode-server, ... }:

# Config shared by all NixOS hosts (devnix, ephem).
{
  imports = [
    vscode-server.nixosModules.default
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Enable (nixos-container) support
  boot.enableContainers = true;

  # Systemd mount dirs
  systemd.tmpfiles.rules = [
    "d /mnt 0755 root root -" # generally for ephemeral mounts
    "d /media 0755 root root -"
  ];

  systemd.settings.Manager.DefaultTimeoutStopSec = "10s";

  # networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;
  networking.nameservers = [ "1.1.1.1" "8.8.8.8" ];
  networking.resolvconf.useLocalResolver = false;

  # Raise inotify limits for VSCode Remote, direnv/devenv, and Claude Code.
  boot.kernel.sysctl = {
    "fs.inotify.max_user_watches" = 1048576;
    "fs.inotify.max_user_instances" = 1024;
    "fs.inotify.max_queued_events" = 65536;
  };

  # Set your time zone.
  time.timeZone = "Europe/Stockholm";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "de_CH.UTF-8";
    LC_IDENTIFICATION = "de_CH.UTF-8";
    LC_MEASUREMENT = "de_CH.UTF-8";
    LC_MONETARY = "de_CH.UTF-8";
    LC_NAME = "de_CH.UTF-8";
    LC_NUMERIC = "de_CH.UTF-8";
    LC_PAPER = "de_CH.UTF-8";
    LC_TELEPHONE = "de_CH.UTF-8";
    LC_TIME = "de_CH.UTF-8";
  };

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "ch";
    variant = "de_mac";
  };

  # Configure console keymap
  console.keyMap = "sg";

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.dylan = {
    isNormalUser = true;
    description = "dylan";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [];
    # set zsh as default shell
    shell = pkgs.zsh;
  };
  programs.zsh.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  services.openssh.enable = true;
  services.envfs.enable = true;
  services.vscode-server.enable = true;

  # enable experimental features
  nix = {
    package = pkgs.nix;
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      trusted-users = [ "root" "dylan" ];
      connect-timeout = 30;
    };
  };

  environment.etc."inputrc".text = ''
   set editing-mode vi
  '';

  # Needed to enable remote development using VSCode SSH-Remote Plugin
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
      stdenv.cc.cc
      zlib
  ];

  ### VIRTUALISATION ###
  virtualisation.docker.enable = true;
  users.extraGroups.docker.members = [ "dylan" ];

  ### SYSTEM-APPS ###
  environment.systemPackages = with pkgs; [
    wget
    git
    tmux
    ncdu
    lazygit
    fastfetch
    fzf
    uv
    ranger
    neovim
    mutagen
    silver-searcher # ag
    claude-code
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
}
