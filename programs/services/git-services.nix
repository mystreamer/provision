{ config, pkgs, lib, serviceFlakes, ... }:

let
  mkService = name: cfg: flake: {

    age.secrets.openai-api-key = {
      file = ../../secrets/openaiApiKey.age;
      mode = "0440";
      owner = "root";
      group = "root";
    };

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
      
      # Bind mount the secret into the container
      bindMounts = {
        "/run/secrets/openai-api-key" = {
          hostPath = config.age.secrets.openai-api-key.path;
          isReadOnly = true;
        };
      };
      
      config = { config, pkgs, ... }: {
        imports = [ flake.nixosModules.default ];

        # Make the API key available as an environment variable
        systemd.services.${name}.environment = {
            OPENAI_API_KEY_FILE = "/run/secrets/openai-api-key";
          };
        
        networking.defaultGateway = {
          address = "192.168.100.1";
          interface = "eth0";
        };
        networking.useNetworkd = lib.mkForce false;
        networking.useDHCP = false;
      };
    };
  };
  
  services = {
    quicktoc = {
      port = 8055;
      index = 0;
    };
    recipe-manager = {
      port = 8045;
      index = 10;
    };
  };

  # Generate NAT forwarding rules from services config
  natForwardPorts = lib.mapAttrsToList (name: cfg: {
    sourcePort = cfg.port;
    destination = "192.168.100.${toString (10 + cfg.index)}:${toString cfg.port}";
    proto = "tcp";
  }) services;

in
{
  imports = [
    (mkService "quicktoc" services.quicktoc serviceFlakes.quicktoc)
    (mkService "yummie" services.recipe-manager serviceFlakes.yummie)
  ];

  networking.nat = {
    enable = true;
    internalInterfaces = ["ve-+"];
    externalInterface = "ens160";
    forwardPorts = natForwardPorts;
  };

}
