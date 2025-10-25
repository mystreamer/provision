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
        systemd.services.${name} = {
          environment = {
            OPENAI_API_KEY_FILE = "/run/secrets/openai-api-key";
          };
          # Or if the service needs it directly as env var:
          serviceConfig.EnvironmentFile = "/run/secrets/openai-api-key";
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
  };
in
{
  imports = [
    (mkService "quicktoc" services.quicktoc serviceFlakes.quicktoc)
  ];
}
