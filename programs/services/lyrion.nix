{ config, ... }:

{
  virtualisation.oci-containers.backend = "docker";
  
  virtualisation.oci-containers.containers.lyrion = {
    image = "ghcr.io/lms-community/lyrionmusicserver:latest";
    ports = [ "0.0.0.0:9000:9000" ];
    volumes = [
      "/var/lib/lyrion/config:/config"
      "/var/lib/lyrion/music:/music"
      "/var/lib/lyrion/playlists:/playlists"
    ];
  };
}
