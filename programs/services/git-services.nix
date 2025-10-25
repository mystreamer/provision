{ config, pkgs, lib, ... }:

let
  mkService = name: cfg: let
    flake = if cfg ? path then
      builtins.getFlake "path:${cfg.path}"
    else
      let
        repo = builtins.fetchGit { url = cfg.repo; ref = cfg.ref; };
      in builtins.getFlake "git+file://${repo}";
    
    # Merge the flake module with container-specific networking
    containerConfig = { config, pkgs, ... }: {
      imports = [ flake.nixosModules.default ];
      
      # Critical: Set the default gateway to the host
      networking.defaultGateway = {
        address = "192.168.100.1";
        interface = "eth0";
      };
      networking.useNetworkd = lib.mkForce false;
      networking.useDHCP = false;
    };
  in {
    containers.${name} = {
      autoStart = true;
      privateNetwork = true;
      hostAddress = "192.168.100.1";
      localAddress = "192.168.100.${toString (10 + cfg.index)}";
      forwardPorts = [{ 
        containerPort = cfg.port;
        hostPort = cfg.port;
        protocol = "tcp";
      }];
      
      config = containerConfig;
    };
  };
  
  services = {
    quicktoc = {
      path = "git@github.com:mystreamer/quick-toc.git";
      port = 8055;
      index = 0;
    };
  };
  
in {
  config = lib.mkMerge [
    (lib.mkMerge (lib.mapAttrsToList mkService services))
    
    {
      networking.nat = {
        enable = true;
        internalInterfaces = [ "ve-+" ];
        externalInterface = "enp0s5";
      };
      networking.firewall = {
        trustedInterfaces = [ "ve-+" ];
        allowedTCPPorts = [ 8055 ];
      };
    }
  ];
}
