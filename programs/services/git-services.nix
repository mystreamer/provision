{ nixpkgs, system }:

let
  mkService = name: cfg: let
    repo = builtins.fetchGit { url = cfg.repo; ref = cfg.ref; };
    flake = builtins.getFlake "git+file://${repo}";
  in {
    containers.${name} = {
      autoStart = true;
      privateNetwork = true;
      hostAddress = "192.168.100.1";
      localAddress = "192.168.100.${toString (10 + cfg.index)}";  # Unique IPs
      forwardPorts = [{ 
        hostPort = cfg.port; 
        containerPort = cfg.port; 
      }];
      
      # Import the nixosModule from the flake
      config = { config, pkgs, ... }: {
        imports = [ flake.nixosModules.default ];
      };
    };
  };
  
  services = {
    quicktoc = {
      # repo = "https://github.com/yourorg/quicktoc";
      # ref = "main";
      path = ../../../quick-toc;
      port = 8080;
      index = 0;
    };
    # Add more services here
    # service-b = {
    #   repo = "https://github.com/yourorg/service-b";
    #   ref = "main";
    #   port = 8081;
    #   index = 1;
    # };
  };
  
in {
  config = nixpkgs.lib.mkMerge (nixpkgs.lib.mapAttrsToList mkService services);
}