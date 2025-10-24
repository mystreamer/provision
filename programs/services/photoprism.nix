{ config, ... }:

{
  age.secrets.photoprismEnv = {
    file = ../../secrets/photoprismEnv.age;
  };

  virtualisation.oci-containers.backend = "docker";
  
  virtualisation.oci-containers.containers.photoprism = {
    image = "photoprism/photoprism:latest";
    ports = [ "127.0.0.1:2342:2342" ];
    volumes = [
      "/var/lib/photoprism/originals:/photoprism/originals"
      "/var/lib/photoprism/storage:/photoprism/storage"
    ];
    environmentFiles = [ config.age.secrets.photoprismEnv.path ];
  };
}

