# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ../../modules/nixos-base.nix
      ../../programs/services
    ];

  services.xserver.enable = true;
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;
  services.xrdp.enable = true;
  services.xrdp.defaultWindowManager = "startplasma-x11";

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
  networking.firewall.allowedTCPPorts = [ 3389 2342 3000 8045 ];
  networking.firewall.allowedUDPPortRanges = [ { from = 60000; to = 61000; } ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?

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
