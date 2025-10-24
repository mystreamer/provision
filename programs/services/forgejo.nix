{ config, ... }:

{
  virtualisation.oci-containers.backend = "docker";
  
  virtualisation.oci-containers.containers.forgejo = {
    image = "codeberg.org/forgejo/forgejo:13";
    ports = [ "0.0.0.0:3000:3000" ];
    volumes = [
      "/var/lib/forgejo:/data"
    ];
  };
}

