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
      ../../programs/services
    ];

  # networking.nat.enable = true;
  # networking.nat.internalInterfaces = ["ve-+"];  # All container interfaces
  # networking.nat.externalInterface = "ens160";

  # Service ports (xrdp's 3389 is opened in modules/desktop.nix)
  networking.firewall.allowedTCPPorts = [ 2342 3000 8045 ];
  networking.firewall.allowedUDPPortRanges = [ { from = 60000; to = 61000; } ];

  # Do not change after install; see `man configuration.nix` / nixos.org options for stateVersion.
  system.stateVersion = "25.05";

  ### SYSTEM-APPS ###
  environment.systemPackages = with pkgs; [
    gh
    cloudflared
    mosh
  ];

  nixpkgs.config.problems.handlers = {
    flet.broken = "warn";
  };

  # age.identityPaths = [ "/home/dylan/.config/sops/age/keys.txt" ];

  # Enable cloudflare tunnel
  age.secrets.cloudflared-creds = {
      file = ../../secrets/cloudflaredCreds.age;
      mode = "0440";
      owner = "root";
      group = "root";
  };
  
  age.secrets.postgresCreds = {
      file = ../../secrets/postgresCreds.age;
      mode = "0440";
      owner = "root";
      group = "root";
  };

  services.cloudflared = {
    enable = true;
    tunnels = {
      "6299e448-c9b3-4f45-b747-cc06da1529ea" = {
        credentialsFile = "${config.age.secrets.cloudflared-creds.path}";
        ingress = {
            "quicktoc.mystreamer.cx" = "http://192.168.100.1:8055";
        };
        default = "http_status:404";
      };
    };
  };

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
          url."git@github.com:".insteadOf = "https://github.com/";
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
