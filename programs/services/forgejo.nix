{ config, ... }:

{
  virtualisation.oci-containers.backend = "docker";
  
  virtualisation.oci-containers.containers.forgejo = {
    image = "codeberg.org/forgejo/forgejo:latest";
    ports = [ "127.0.0.1:3000:3000" ];
    volumes = [
      "/var/lib/forgejo:/data"
    ];
  };
}

